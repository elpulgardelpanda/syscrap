defmodule Syscrap.Aggregator.Worker do
  use Supervisor

  @moduledoc """
    Aggregation worker for a single `Target`. It supervises
    every `Metric` configured for this `Target`.
  """

  def start_link(opts), do: Supervisor.start_link(__MODULE__, opts)

  def init(opts) do

    # TODO: add Aggregator.Metrics for each Metric configured for this Target
    children = []

    supervise(children, strategy: :one_for_one)
  end


end