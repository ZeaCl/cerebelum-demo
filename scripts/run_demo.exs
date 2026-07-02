# Cerebelum Demo — Run workflows from the command line
#
# Usage:
#   iex -S mix run scripts/run_demo.exs order
#   iex -S mix run scripts/run_demo.exs pipeline
#   iex -S mix run scripts/run_demo.exs onboarding

alias CerebelumDemo.Workflows.{OrderWorkflow, PipelineWorkflow, LongRunningWorkflow}

workflow_type = System.argv() |> List.first() || "order"

case workflow_type do
  "order" ->
    IO.puts("\n📦 Running OrderWorkflow...")
    {:ok, exec} = Cerebelum.execute_workflow(OrderWorkflow, %{
      order: %{
        id: "ORD-123",
        items: [
          %{name: "Widget", price: 25},
          %{name: "Gadget", price: 75}
        ]
      }
    })
    Process.sleep(500)
    {:ok, status} = Cerebelum.get_execution_status(exec.id)
    IO.inspect(status.state, label: "Status")
    IO.inspect(status.results, label: "Results")

  "pipeline" ->
    IO.puts("\n🚀 Running PipelineWorkflow...")
    {:ok, exec} = Cerebelum.execute_workflow(PipelineWorkflow, %{
      project: "cerebelum-demo"
    })
    Process.sleep(2000)
    {:ok, status} = Cerebelum.get_execution_status(exec.id)
    IO.inspect(status.state, label: "Status")
    IO.inspect(status.completed_steps, label: "Steps completed")

  "onboarding" ->
    IO.puts("\n👤 Running LongRunningWorkflow (onboarding)...")
    {:ok, exec} = Cerebelum.execute_workflow(LongRunningWorkflow, %{
      user: %{email: "dev@example.com", name: "Carlos"}
    })
    Process.sleep(5000)
    {:ok, status} = Cerebelum.get_execution_status(exec.id)
    IO.inspect(status.state, label: "Status")
    IO.inspect(status.results, label: "Results")

  _ ->
    IO.puts("Usage: mix run scripts/run_demo.exs [order|pipeline|onboarding]")
end
