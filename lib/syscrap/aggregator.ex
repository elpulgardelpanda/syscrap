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
    children = []

    supervise(children, strategy: :one_for_one)
  end
end
