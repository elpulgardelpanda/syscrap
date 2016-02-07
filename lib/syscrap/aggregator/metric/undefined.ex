require Logger, as: L

defmodule Syscrap.Aggregator.Metric.Undefined do
  @moduledoc """
    Special module to accomodate a wrapper whose `Metric` module could
    not be identified by its string value on db.

    It's a non catastrophic (nor strange) case, since the `Metric` module
    for this `Aggregator.Wrapper` is devised from a string value on db, and that
    string may be manipulated by humans.

    Therefore that failure is logged as an error (every 10min, which should be seen by humans,
    or at least notified to them), but the wrapper process is spawn to keep the
    hierarchy schema. See `Syscrap.Aggregator.Worker.get_metric_module/1`.
  """

  @behaviour Syscrap.Aggregator.Metric

  def gather_loop(args) do
    L.error("Did not found any Metric module for '#{inspect args[:data]}'")
    :timer.sleep(600000)
    gather_loop(args)
  end

end
