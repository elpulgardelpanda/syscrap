defmodule Syscrap do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Here are my pool options
    mongo_pool_opts = [
      name: {:local, :mongo_pool},
      worker_module: Syscrap.MongoConnection,
      size: 5,
      max_overflow: 10
    ]

    mongo_worker_opts = [
      # no auth, nothing needed by now
    ]

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Syscrap.Worker, [arg1, arg2, arg3])
      :poolboy.child_spec(:mongo_pool, mongo_pool_opts, mongo_worker_opts)
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Syscrap.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
