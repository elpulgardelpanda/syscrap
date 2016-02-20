use Mix.Config

# path to tmp on production filesystem
config :syscrap,
  tmp_path: "~/syscrap/tmp",
  ssh_module: SSHEx

config :logger,
  handle_otp_reports: true,
  handle_sasl_reports: true,
  utc_log: true

config :bottler, :params, [servers: [server1: [ip: "1.1.1.1"],
                                     server2: [ip: "1.1.1.2"]],
                           remote_user: "produser" ]
