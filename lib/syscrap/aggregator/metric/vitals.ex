defmodule Syscrap.Aggregator.Metric.Vitals do

  @moduledoc """
    Metric that gathers general vitals information, like CPU, RAM, swap & disk.
  """

  @behaviour Syscrap.Aggregator.Metric

  def start_gathering(opts) do

    # DB: INSERT Aggregation for a metric,target,type,tag
    # DB: DELETE size capped Aggregations for a metric,target,type,tag

  end
end
