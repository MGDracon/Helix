use Mix.Config

prefix = "${HELIX_DB_PREFIX}"

config :comeonin, :bcrypt_log_rounds, 14

config :helix_account, Helix.Account.Repo,
  size: "${HELIX_DB_POOL_SIZE}",
  username: "${HELIX_DB_USER}",
  password: "${HELIX_DB_PASS}",
  hostname: "${HELIX_DB_HOST}",
  database: prefix <> "_prod_account"

config :guardian, Guardian,
  secret_key: "${HELIX_JWT_KEY}"