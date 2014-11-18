defmodule Syscrap.Reactor.Worker do
  use GenServer

  @moduledoc """
    Process responsible for firing a specific alert for the given `Reaction`.
  """

  def start_link(opts) do
    name = String.to_atom("Reactor.Worker for #{opts[:name]}")
    GenServer.start_link(__MODULE__, opts, [name: name])
  end

  def init(opts) do

    # TODO: start gathering loop for the requested metric and the given `Target`

    {:ok, opts}
  end
end