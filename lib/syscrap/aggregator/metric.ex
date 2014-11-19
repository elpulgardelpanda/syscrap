defmodule Syscrap.Aggregator.Metric do
  use GenServer

  @moduledoc """
    Process responsible for gathering a specific metric for the given `Target`.
  """

  def start_link(opts) do
    name = String.to_atom("#{opts[:metric]} Metric for #{opts[:name]}")
    GenServer.start_link(__MODULE__, opts, [name: name])
  end

  def init(opts) do

    # TODO: start gathering loop for the requested metric and the given `Target`

    {:ok, opts}
  end
end