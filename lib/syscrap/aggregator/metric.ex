defmodule Syscrap.Aggregator.Metric do
  use GenServer

  @moduledoc """
    Process responsible for gathering a specific metric for the given `Target`.
  """

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts)

  def init(opts) do

    # TODO: start gathering loop for the requested metric and the given `Target`

    {:ok, opts}
  end
end