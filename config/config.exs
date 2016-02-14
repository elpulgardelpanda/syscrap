use Mix.Config

# config :logger,
#   utc_log: true,
#   handle_otp_reports: true,
#   handle_sasl_reports: true



config :syscrap,
  notificator_worker_count: 1, # by now, no concurrency problems
  mongo_pool_opts:    [name: {:local, Syscrap.MongoPool},
                       worker_module: Syscrap.MongoWorker,
                       size: 5,
                       max_overflow: 10],
  mongo_db_opts:      [database: "syscrap"],
  aggregator_popopts: [step: 3000],
  reactor_popopts:    [step: 3000],
  ssh_opts:           [connect: [user_dir: "~/.ssh" |> Path.expand |> to_char_list, # where to look for id_rsa keys, they should have access to every target machine
                                 silently_accept_hosts: true,
                                 connect_timeout: :infinity, # transport layer timeout
                                 idle_time: :infinity], # idle connection timeout
                       negotiation_timeout: 5000, # connection establishment timeout
                       port: 22],
  ssh_module: :ssh # testability


# Add configuration based on env
import_config "#{Mix.env}.exs"

if Mix.env == :prod, do: import_config "private_config.exs"
