# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for third-
# party users, it should be done in your mix.exs file.

# Sample configuration:
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]

# This file is not on the repo. Look at private_config.exs.example for a
# starting point.

config :syscrap,
  notificator_worker_count: 1, # by now, no concurrency problems
  mongo_pool_opts: [size: 5, max_overflow: 10],
  mongo_db_opts: [database: "syscrap"]

# Add configuration based on env
import_config "#{Mix.env}.exs"

if Mix.env == :prod, do: import_config "private_config.exs"
