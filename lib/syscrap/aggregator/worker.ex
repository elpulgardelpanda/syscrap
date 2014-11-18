defmodule Syscrap.Aggregator.Worker do
  use Supervisor

  @moduledoc """
    Aggregation worker for a single `Target`. It supervises
    every `Metric` configured for this `Target`.
  """

  def start_link(opts) do
    name = String.to_atom("Aggregator.Worker for " <> opts[:name])
    Supervisor.start_link(__MODULE__, opts, [name: name])
  end

  def init(opts) do

    # TODO: add Aggregator.Metrics for each Metric configured for this Target
    metrics = [[metric: :vitals],
               [metric: :traffic],
               [metric: :logs]]
    children = for m <- metrics do
      m = Keyword.merge(m,[name: opts[:name]])
      worker(Syscrap.Aggregator.Metric, [m], [id: m[:metric]])
    end

    supervise(children, strategy: :one_for_one)
  end
end