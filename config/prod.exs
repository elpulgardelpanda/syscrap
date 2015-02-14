use Mix.Config

# path to tmp on production filesystem
config :syscrap, :tmp_path, "~/syscrap/tmp"

config :logger,
  handle_otp_reports: true,
  handle_sasl_reports: true,
  utc_log: true
