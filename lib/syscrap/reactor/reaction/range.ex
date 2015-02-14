defmodule Syscrap.Reactor.Reaction.Range do

  @moduledoc """
    Reaction that checks for given metrics on given targets to be within
    given ranges.

    Targets, metrics and ranges are read from DB, just as the values to check.
  """

  @behaviour Syscrap.Reactor.Reaction

  def start_checking(opts) do
  end
end
