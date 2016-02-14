defmodule Syscrap.Aggregator.Metric.POL.Socket do
  @behaviour Syscrap.Aggregator.Metric

  def gather_loop(opts) do
    :timer.sleep(1000)
    gather_loop(opts)
  end
end
