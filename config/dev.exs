import Config

# Dev-specific overrides
config :cerebelum, Cerebelum.Repo,
  show_sensitive_data_on_connection_error: true,
  pool_size: 5
