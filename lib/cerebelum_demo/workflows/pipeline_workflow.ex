defmodule CerebelumDemo.Workflows.PipelineWorkflow do
  @moduledoc """
  Demo: CI/CD pipeline with parallel stages and approval gates.
  """
  use Cerebelum.Workflow

  workflow do
    timeline do
      build() |> test_unit() |> security_scan() |> deploy_staging() |> approval_gate() |> deploy_prod()
    end

    diverge from: build() do
      {:error, :network} -> back_to(:build)
      {:error, _} -> :failed
    end

    diverge from: security_scan() do
      {:error, :vulnerability_found} -> :failed
      {:error, :timeout} -> back_to(:security_scan)
    end

    branch after: deploy_staging(), on: result do
      result[:health] == :ok -> :continue
      true -> :failed
    end
  end

  # ── Steps ──

  def build(context) do
    project = context.inputs[:project] || "my-app"
    IO.puts("🔨 Building #{project}...")
    Process.sleep(100)
    {:ok, %{build_id: "B-#{:rand.uniform(999)}", status: :ok}}
  end

  def test_unit(_context, {:ok, build}) do
    IO.puts("🧪 Running unit tests...")
    Process.sleep(200)
    {:ok, Map.put(build, :tests, %{passed: 42, failed: 0})}
  end

  def security_scan(_context, {:ok, _prev}, {:ok, build}) do
    IO.puts("🔒 Running security scan...")
    Process.sleep(150)
    {:ok, Map.put(build, :security, :clean)}
  end

  def deploy_staging(_context, {:ok, _p0}, {:ok, _p1}, {:ok, build}) do
    IO.puts("🚀 Deploying to staging...")
    Process.sleep(300)
    result = build |> Map.put(:staging_url, "https://staging.example.com") |> Map.put(:health, :ok)
    {:ok, result}
  end

  def approval_gate(_context, {:ok, _p0}, {:ok, _p1}, {:ok, _p2}, {:ok, build}) do
    IO.puts("⏳ Waiting for approval to deploy to production...")
    result = build |> Map.put(:approved, true) |> Map.put(:approved_by, "admin")
    {:ok, result}
  end

  def deploy_prod(_context, {:ok, _p0}, {:ok, _p1}, {:ok, _p2}, {:ok, _p3}, {:ok, build}) do
    IO.puts("🚀 Deploying to production!")
    {:ok, Map.put(build, :prod_url, "https://example.com")}
  end
end
