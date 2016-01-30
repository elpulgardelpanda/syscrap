require Syscrap.Helpers, as: H
alias Syscrap.Aggregator, as: Agg

defmodule Syscrap do
  @moduledoc """
    Main Syscrap Application
  """

  use Application

  def start(_type, _args), do: Syscrap.Supervisor.start_link

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

defmodule Syscrap.Supervisor do
  use Supervisor

  def start_link(_args \\ []), do: Supervisor.start_link(__MODULE__, [], name: __MODULE__)

  def init(_args) do

    # respond to harakiri restarts
    tmp_path = H.env(:tmp_path, "tmp") |> Path.expand
    Harakiri.add %{ paths: ["#{tmp_path}/restart"],
                    action: :restart }, create_paths: true

    # configuration for the Aggregator populator
    agg_args = [name: Syscrap.AggregatorPopulator,
                step: 30000,
                run_args: [Agg,
                           &Agg.child_spec/2,
                           &Agg.desired_children/1]]

    children = [supervisor(Syscrap.MongoPool, [[database: "syscrap"]]),
                supervisor(Agg, [[]]),
                supervisor(Syscrap.Notificator, [[]]),
                supervisor(Syscrap.Reactor, [[]]),
                worker(Task, [Syscrap,:alive_loop, [[name: :syscrap_alive_loop]]]),
                worker(Task, [Populator.Looper, :run, [agg_args]], [id: agg_args[:name]])]

    supervise(children, strategy: :one_for_one,
                        max_restarts: Enum.count(children) + 1,
                        max_seconds: 5)
  end
end
