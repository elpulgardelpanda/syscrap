use Mix.Config

# anything else


config :syscrap,
  aggregator_popopts: [step: 1000],
  reactor_popopts: [step: 1000],
  ssh_module: Syscrap.Mocks.SSHAllOK
