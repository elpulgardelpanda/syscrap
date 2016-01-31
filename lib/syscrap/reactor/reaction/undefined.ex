require Logger, as: L

defmodule Syscrap.Reactor.Reaction.Undefined do
  @moduledoc """
    Special module to accomodate a worker whose `Reaction` module could
    not be identified by its string value on db.

    It's a non catastrophic (nor strange) case, since the `Reaction` module
    for this `Reactor.Worker` is devised from a string value on db, and that
    string may be manipulated by humans.

    Therefore that failure is logged as an error (every 10min, which should be seen by humans,
    or at least notified to them), but the worker process is spawn to keep the
    hierarchy schema. See `Syscrap.Reactor.get_reaction_module/1`.
  """

  @behaviour Syscrap.Reactor.Reaction

  def check_loop(args) do
    L.error("Did not found any Reaction module for '#{inspect args[:data]}'")
    :timer.sleep(600000)
    check_loop(args)
  end

end
