defmodule CerebelumDemo.Workflows.OrderWorkflow do
  @moduledoc """
  Demo: E-commerce order processing.

  Shows timeline, diverge (error handling), and branch (conditional routing).
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

    # Handle validation errors
    diverge from: validate_order() do
      {:error, :invalid_data} -> :failed
      {:error, :timeout} -> back_to(:validate_order)
    end

    # Handle inventory issues
    diverge from: check_inventory() do
      {:error, :out_of_stock} -> :failed
    end

    # Business logic routing
    branch after: process_payment(), on: result do
      result[:amount] > 1000 -> :high_value_path
      true -> :standard_path
    end
  end

  # ── Step implementations ──

  def validate_order(context) do
    order = context.inputs[:order]
    if order && order[:id], do: {:ok, order}, else: {:error, :invalid_data}
  end

  def check_inventory(_context, order) do
    in_stock = Map.get(order, :items, []) |> length() > 0
    if in_stock, do: {:ok, order}, else: {:error, :out_of_stock}
  end

  def process_payment(_context, order) do
    total = order[:items] |> Enum.reduce(0, & &1[:price] + &2)
    {:ok, %{order: order, amount: total, status: :paid}}
  end

  def ship_order(_context, payment) do
    {:ok, %{tracking: "TRK-#{:rand.uniform(9999)}", carrier: "FedEx"}}
  end

  def notify_customer(_context, shipment) do
    IO.puts("📦 Order shipped! Tracking: #{shipment[:tracking]}")
    {:ok, :notified}
  end
end
