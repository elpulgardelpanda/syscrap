defmodule Syscrap.Aggregator do
  use Supervisor

  @moduledoc """
    Main aggregation supervisor
  """

  def start_link, do: Supervisor.start_link(__MODULE__, [])

  def init([]) do

    # TODO: add Aggregator.Workers
    children = []

    supervise(children, strategy: :one_for_one)
  end
end
