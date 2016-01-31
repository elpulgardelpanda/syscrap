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
    supervise([], strategy: :one_for_one,
                  max_restarts: 3,
                  max_seconds: 5)
  end

  @doc """
    Populator desired_children function
  """
  def desired_children(_) do
    H.spit H.Db.find("targets")
    H.Db.find("targets")
  end

  @doc """
    Populator child_spec function
  """
  def child_spec(data, _) do
    data = data |> H.defaults(%{"name" => data["target"]})

    H.spit data
    name = String.to_atom("Worker for " <> data["name"])
    data = Keyword.put(data, "name", name)
    supervisor(Syscrap.Aggregator.Worker, [data], [id: data["name"]])
  end

end
