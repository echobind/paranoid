use Mix.Config

config :paranoid, Paranoid.TestRepo,
  hostname: "localhost",
  database: "paranoid_test",
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox

config :logger, level: :warn
