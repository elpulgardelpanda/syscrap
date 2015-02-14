defmodule Syscrap.Aggregator.Worker do
  use Supervisor

  @moduledoc """
    Aggregation worker for a single `Target`. It supervises
    every `Wrapper` configured for this `Target`.
  """

  def start_link(opts) do
    name = String.to_atom("Worker for " <> opts[:name])
    Supervisor.start_link(__MODULE__, opts, [name: name])
  end

  def init(opts) do
    alias Syscrap.Aggregator.Metric, as: M

    # TODO: get `target_metrics` from db
    target_metrics = ["Vitals","Traffic","POL.File"]

    # TODO: a way to get `all_metrics` ?
    all_metrics = [ M.Vitals, M.Traffic, M.Logs,
                    M.POL.File, M.POL.Port, M.POL.Socket ]

    metrics = Enum.filter(all_metrics, fn(m) ->
                            String.contains?(to_string(m),target_metrics)
                          end)

    # TODO: get SSH connection and add it to data being passed to wrappers

    children = for m <- metrics do
      data = [metric: m, name: opts[:name]]
      worker(Syscrap.Aggregator.Wrapper, [data], [id: data[:metric]])
    end

    supervise(children, strategy: :one_for_one)
  end
end
