defmodule Syscrap.Aggregator.Wrapper do
  use GenServer

  @moduledoc """
    Process responsible for gathering a specific metric for the given `Target`.
  """

  def start_link(args) do
    name = String.to_atom("#{args[:options][:metric_name]} for #{args[:target]}")
    GenServer.start_link(__MODULE__, args, [name: name])
  end

  def init(args) do
    Task.async(args[:metric], :gather_loop, [args])
    {:ok, args}
  end
end
