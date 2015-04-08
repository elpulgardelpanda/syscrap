defmodule Syscrap.Reactor do
  use Supervisor

  @moduledoc """
    Main reaction supervisor. It spawns and supervises one
    `Reactor.Worker` for each `Reaction` defined module on the system.
  """

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, [name: __MODULE__])
  end

  def init(opts) do
    alias Syscrap.Reactor.Reaction, as: R

    # TODO: a way to get defined `reactions` ?
    reactions = [ R.Range ]

    children = for r <- reactions do
      data = [reaction: r]
      worker(Syscrap.Reactor.Worker, [data], [id: r])
    end

    supervise(children, strategy: :one_for_one, max_restarts: Enum.count(children) + 1)
  end
end
