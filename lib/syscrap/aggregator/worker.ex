require Syscrap.Helpers, as: H

defmodule Syscrap.Aggregator.Worker do
  use Supervisor

  @moduledoc """
    Aggregation worker for a single `Target`. It supervises
    every `Wrapper` configured for this `Target`.
  """

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, [name: opts[:name]])
  end

  def init(opts) do
    alias Syscrap.Aggregator.Metric, as: M

    # retrieve aggregation_options for this target
    aggopts = get_aggopts(opts)

    # get SSH connection with the target
    {:ok, ssh} = establish_ssh_connection(opts)

    # build children specs based on all that
    children = build_children_specs(opts, aggopts[:metrics], ssh)

    # go on
    supervise( children, strategy: :one_for_one )
  end

  # Hide some param sanitizing needed by erlang's `:ssh`
  #
  defp establish_ssh_connection(opts) do
    opts = opts |> H.defaults(ssh_module: :ssh)

    target = opts[:data][:target] |> to_char_list
    user = opts[:data][:user] |> to_char_list
    connect_opts = H.env(:ssh_opts)[:connect] |> Keyword.merge(user: user)

    opts[:ssh_module].connect(target,
                              H.env(:ssh_opts)[:port],
                              connect_opts,
                              H.env(:ssh_opts)[:negotiation_timeout])
  end

  # Get aggregation_options for this target from DB.
  # Always returns a usable map, even when no result is found on db.
  #
  defp get_aggopts(opts) do
    H.Db.find("aggregation_options", %{"target": opts[:data][:target]})
    |> Enum.at(0, %{metrics: %{}})
  end

  # Get the actual `Metric` module from given string,
  # or else return `Syscrap.Aggregator.Metric.Undefined` and log the issue.
  #
  defp get_metric_module(metric) do
    try do
      String.to_existing_atom "Elixir.Syscrap.Aggregator.Metric.#{metric}"
    rescue
      ArgumentError -> Syscrap.Aggregator.Metric.Undefined
    end
  end

  # Add useful metadata to given options Map.
  # Receives also the key (the Metric name from db).
  # Returns a single Map with all data included.
  #
  defp add_metadata(key, options) do
    options |> Map.merge(%{metric_name: key})
  end

  # Given db metrics definition, returns a map of
  # metric modules as keys and a map with their options as values.
  #
  defp parse_metrics(db_data) do
    db_data
    |> Enum.map(fn({k,v})-> {get_metric_module(k), add_metadata(k,v)} end)
    |> Enum.into(%{})
  end

  # Given db metrics definition and ssh handle,
  # returns list of children specs for the supervisor.
  #
  defp build_children_specs(opts, metrics, ssh) do
    for {m, o} <- parse_metrics(metrics) do
      data = [target: opts[:data][:target],
              metric: m, options: o, ssh: ssh]
      worker(Syscrap.Aggregator.Wrapper, [data], [id: data[:metric]])
    end
  end
end
