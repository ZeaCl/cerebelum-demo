"""
Demo: E-commerce workflow in Python — NO recompilation needed.

Usage:
  # Local mode (no engine required):
  python examples/python/01_local_workflow.py

  # Distributed mode (requires iex -S mix running in another terminal):
  python examples/python/01_local_workflow.py --distributed
"""

import asyncio
import sys
from cerebelum import step, workflow, Context
from cerebelum import LocalExecutor, DistributedExecutor


# ── Step definitions ──────────────────────────────────────

@step
async def validate_order(context: Context, inputs: dict):
    order = inputs.get("order", {})
    if order.get("id"):
        return {"ok": order}
    return {"error": "invalid_data"}


@step
async def check_inventory(context: Context, validate_order: dict):
    order = validate_order
    items = order.get("items", [])
    if len(items) > 0:
        return {"ok": order}
    return {"error": "out_of_stock"}


@step
async def process_payment(context: Context, validate_order: dict, check_inventory: dict):
    order = validate_order
    items = order.get("items", [])
    total = sum(item.get("price", 0) for item in items)
    return {"ok": {"order": order, "amount": total, "status": "paid"}}


@step
async def ship_order(context: Context, _v, _c, process_payment: dict):
    import random
    payment = process_payment
    return {"ok": {"tracking": f"TRK-{random.randint(1000, 9999)}", "carrier": "FedEx"}}


@step
async def notify_customer(context: Context, _v, _c, _p, ship_order: dict):
    shipment = ship_order
    print(f"📦 Order shipped! Tracking: {shipment['tracking']}")
    return {"ok": "notified"}


# ── Workflow definition ───────────────────────────────────

@workflow
def order_workflow(wf):
    wf.timeline(
        validate_order
        >> check_inventory
        >> process_payment
        >> ship_order
        >> notify_customer
    )


# ── Execute ───────────────────────────────────────────────

async def main():
    distributed = "--distributed" in sys.argv

    inputs = {
        "order": {
            "id": "ORD-123",
            "items": [
                {"name": "Widget", "price": 25},
                {"name": "Gadget", "price": 75},
            ]
        }
    }

    if distributed:
        print("🌐 Distributed mode (gRPC → cerebelum engine)")
        executor = DistributedExecutor(core_url="localhost:50051")
        result = await executor.execute(order_workflow, inputs)
    else:
        print("💻 Local mode (pure Python, no engine)")
        result = await order_workflow.execute(inputs)

    print(f"Status: {result.state}")
    print(f"Results: {result.results}")


if __name__ == "__main__":
    asyncio.run(main())
