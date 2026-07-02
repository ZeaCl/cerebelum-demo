defmodule CerebelumDemo.MixProject do
  use Mix.Project

  def project do
    [
      app: :cerebelum_demo,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      mod: {CerebelumDemo.Application, []},
      extra_applications: [:logger, :postgrex, :ecto_sql]
    ]
  end

  defp deps do
    [
      {:cerebelum, github: "ZeaCl/cerebelum"},
      {:bandit, "~> 1.5"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "cmd mix cerebelum.setup || echo 'cerebelum setup skipped'"]
    ]
  end
end
