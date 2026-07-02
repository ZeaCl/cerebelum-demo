defmodule CerebelumDemo.Workflows.OrderWorkflow do
  @moduledoc """
  Demo: E-commerce order processing.

  Steps receive previous results as {:ok, value} or {:error, reason} tuples.
  """
  use Cerebelum.Workflow

  workflow do
    timeline do
      validate_order()
      |> check_inventory()
      |> process_payment()
      |> ship_order()
      |> notify_customer()
    end

    diverge from: validate_order() do
      {:error, :invalid_data} -> :failed
      {:error, :timeout} -> back_to(:validate_order)
    end

    diverge from: check_inventory() do
      {:error, :out_of_stock} -> :failed
    end

    branch after: process_payment(), on: result do
      result[:amount] > 1000 -> skip_to(:notify_customer)
      true -> :continue
    end
  end

  # ── Steps ──

  def validate_order(context) do
    order = context.inputs[:order]
    if order && order[:id], do: {:ok, order}, else: {:error, :invalid_data}
  end

  def check_inventory(_context, {:ok, order}) do
    items = order[:items] || []
    if length(items) > 0, do: {:ok, order}, else: {:error, :out_of_stock}
  end

  def process_payment(_context, {:ok, _prev}, {:ok, order}) do
    total = (order[:items] || []) |> Enum.reduce(0, &(&1[:price] || 0) + &2)
    {:ok, %{order: order, amount: total, status: :paid}}
  end

  def ship_order(_context, {:ok, _prev1}, {:ok, _prev2}, {:ok, payment}) do
    {:ok, %{tracking: "TRK-#{:rand.uniform(9999)}", carrier: "FedEx"}}
  end

  def notify_customer(_context, {:ok, _prev1}, {:ok, _prev2}, {:ok, _prev3}, {:ok, shipment}) do
    IO.puts("📦 Order shipped! Tracking: #{shipment[:tracking]}")
    {:ok, :notified}
  end
end
