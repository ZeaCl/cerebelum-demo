import Config

# ── cerebelum engine ──
config :cerebelum,
  ecto_repos: [Cerebelum.Repo]

config :cerebelum, Cerebelum.Repo,
  database: "cerebelum_demo_dev",
  username: System.get_env("DB_USER", "dev"),
  hostname: System.get_env("DB_HOST", "localhost"),
  pool_size: 10

config :cerebelum_demo,
  ecto_repos: [Cerebelum.Repo]

# ── cerebelum features ──
config :cerebelum,
  # HTTP REST API
  http_enabled: true,
  http_port: 4001,

  # gRPC for Python workers
  enable_grpc_server: false,
  grpc_port: 50051,

  # Workflow resurrection
  enable_workflow_resurrection: true,
  resurrection_scan_interval_ms: 30_000

import_config "#{config_env()}.exs"
