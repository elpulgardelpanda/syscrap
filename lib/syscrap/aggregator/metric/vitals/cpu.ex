defmodule Syscrap.Aggregator.Metric.Vitals.CPU do

  @moduledoc """
    Metric that gathers CPU information
  """

  @behaviour Syscrap.Aggregator.Metric

  def gather_loop(opts) do

    # DB: INSERT Aggregation for a metric,target,type,tag
    # DB: DELETE size capped Aggregations for a metric,target,type,tag

  end
end
