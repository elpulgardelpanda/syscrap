defmodule Syscrap.Reactor.Worker do
  use GenServer

  @moduledoc """
    Process responsible for firing a specific alert for the given `Reaction`.
  """

  def start_link(opts) do
    name = String.to_atom("Worker for #{to_string(opts[:reaction])}")
    GenServer.start_link(__MODULE__, opts, [name: name])
  end

  def init(opts) do

    # DB: FIND all ReactionTargets for this reaction
    # DB: FIND the ReactionOptions for this reaction

    opts[:reaction].start_checking(opts)
    {:ok, opts}
  end
end
