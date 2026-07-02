defmodule CerebelumDemo.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    # cerebelum already starts: Repo, EventStore, Engine, Registry, etc.
    # We only add HTTP API + PubSub

    children = [
      {Phoenix.PubSub, name: Cerebelum.API.PubSub},
      Cerebelum.API.Endpoint
    ]

    opts = [strategy: :one_for_one, name: CerebelumDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
