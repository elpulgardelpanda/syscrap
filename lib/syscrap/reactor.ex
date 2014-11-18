defmodule Syscrap.Reactor do
  use Supervisor

  @moduledoc """
    Main reaction supervisor. It spawns and supervises one
    `Reactor.Worker` for each `Reaction` defined on DB.
  """

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, [name: Syscrap.Reactor])
  end

  def init(opts) do

    # TODO: add Reactor.Workers for each Reaction defined on DB
    reactions = [[name: "name1"],
                 [name: "name2"],
                 [name: "name3"]]

    children = for r <- reactions do
      worker(Syscrap.Reactor.Worker, [r], [id: r[:name]])
    end

    supervise(children, strategy: :one_for_one)
  end
end
