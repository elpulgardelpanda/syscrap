require Syscrap.Helpers, as: H

defmodule Syscrap.Aggregator do
  use Supervisor

  @moduledoc """
    Main aggregation supervisor. It spawns and supervises one
    `Aggregator.Worker` for each `Target` defined on DB.
  """

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, [name: Syscrap.Aggregator])
  end

  def init(_) do
    children = for t <- find_all_targets do
      H.spit t
      supervisor(Syscrap.Aggregator.Worker, [t], [id: t[:name]])
    end

    supervise(children, strategy: :one_for_one,
                        max_restarts: Enum.count(children) + 1,
                        max_seconds: 5)
  end

  defp find_all_targets do
    Syscrap.Mongo.find("targets")
  end
end
