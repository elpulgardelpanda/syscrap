defmodule Syscrap.Aggregator do
  use Supervisor

  @moduledoc """
    Main aggregation supervisor. It spawns and supervises one
    `Aggregator.Worker` for each `Target` defined on DB.
  """

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, [name: Syscrap.Aggregator])
  end

  def init(opts) do

    # TODO: add Aggregator.Workers for each Target defined on DB
    # DB: FIND all Targets
    targets = [ [name: "name1",ip: "ip1",port: "port1",user: "user1"],
                [name: "name2",ip: "ip2",port: "port2",user: "user2"],
                [name: "name3",ip: "ip3",port: "port3",user: "user3"] ]

    children = for t <- targets do
      supervisor(Syscrap.Aggregator.Worker, [t], [id: t[:name]])
    end

    supervise(children, strategy: :one_for_one, max_restarts: Enum.count(children) + 1)
  end
end
