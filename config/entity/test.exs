use Mix.Config

prefix = System.get_env("HELIX_DB_PREFIX") || "helix"

config :helix, Helix.Entity.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: prefix <> "_test_entity",
  ownership_timeout: 90_000
