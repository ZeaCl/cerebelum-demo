defmodule CerebelumDemo.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Cerebelum.Repo,
      Cerebelum.EventStore,
      Cerebelum.Execution.Registry,
      Cerebelum.Execution.Supervisor,
      Cerebelum.Infrastructure.WorkerRegistry,
      Cerebelum.Infrastructure.TaskRouter,
      Cerebelum.Infrastructure.BlueprintRegistry,
      Cerebelum.Infrastructure.ExecutionStateManager,
      Cerebelum.Infrastructure.DLQ,
      Cerebelum.Execution.Resurrector,
      Cerebelum.Infrastructure.WorkflowScheduler,
      {Phoenix.PubSub, name: Cerebelum.API.PubSub},
      Cerebelum.API.Endpoint
    ]

    opts = [strategy: :one_for_one, name: CerebelumDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
