defmodule Syscrap.Aggregator.Wrapper do
  use GenServer

  @moduledoc """
    Process responsible for gathering a specific metric for the given `Target`.
  """

  def start_link(opts) do
    name = String.to_atom("#{opts[:metric]} for #{opts[:name]}")
    GenServer.start_link(__MODULE__, opts, [name: name])
  end

  def init(opts) do
    opts[:metric].start_gathering(opts)
    {:ok, opts}
  end
end