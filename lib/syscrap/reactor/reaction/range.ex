require Logger, as: L
require Syscrap.Helpers, as: H

defmodule Syscrap.Reactor.Reaction.Range do

  @moduledoc """
    Reaction that checks for given metrics on given targets to be within
    given ranges.

    Targets, metrics and ranges are read from DB, just as the values to check.
  """

  @behaviour Syscrap.Reactor.Reaction

  def check_loop(args) do
    # DB: FIND last Aggregation for a metric,target,type
    # DB: FINDandMODIFY some Aggregations for a metric,target,type
    # DB: INSERT Notification for a target,type
    :timer.sleep(1000)
    check_loop(args)
  end


end
