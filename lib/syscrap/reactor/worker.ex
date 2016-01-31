defmodule Syscrap.Reactor.Worker do
  use GenServer

  @moduledoc """
    Process responsible for firing a specific alert for the given `Reaction`.
  """

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [name: args[:name]])
  end

  def init(args) do
    {:ok, _} = Task.spawn_link(args[:reaction], :check_loop, args)
    {:ok, args}
  end
end
