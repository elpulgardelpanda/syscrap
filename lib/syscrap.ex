require Syscrap.Helpers, as: H

defmodule Syscrap do
  @moduledoc """
    Main Syscrap Application
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # respond to harakiri restarts
    tmp_path = H.env(:tmp_path, "tmp") |> Path.expand
    Harakiri.Worker.add %{ paths: ["#{tmp_path}/restart"],
                           app: :syscrap,
                           action: :restart }

    # Here are my pool options
    mongo_pool_opts = [ name: {:local, :mongo_pool},
                        worker_module: Syscrap.Mongo,
                        size: 5,
                        max_overflow: 10 ]

    # no auth, nothing needed by now
    mongo_worker_opts = [ ]

    children = [  supervisor(Syscrap.Notificator, [[]]),
                  supervisor(Syscrap.Aggregator, [[]]),
                  supervisor(Syscrap.Reactor, [[]]),
                  :poolboy.child_spec(:mongo_pool, mongo_pool_opts, mongo_worker_opts),
                  worker(Task, [Syscrap,:alive_loop,[[name: :syscrap_alive_loop]]]) ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Syscrap.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
    Tell the world outside we are alive
  """
  def alive_loop(opts \\ []) do
    # register the name if asked
    if opts[:name], do: Process.register(self,opts[:name])

    tmp_path = H.env(:tmp_path, "tmp") |> Path.expand
    :os.cmd 'touch #{tmp_path}/alive'
    :timer.sleep 5_000
    alive_loop
  end
end
