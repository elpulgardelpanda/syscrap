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
    # defer the actual work
    spawn_link(Syscrap.Aggregator.Worker, :do_work, [opts])

    # init the (for now) empty supervisor
    supervise([], strategy: :one_for_one)
  end

  # Do the actual Worker's work
  #
  def do_work(opts) do
    # retrieve aggregation_options for this target
    aggopts = get_aggopts(opts)

    # get SSH connection with the target
    {:ok, ssh} = loop_to_establish_ssh_connection(opts)

    # build children specs based on all that
    build_children_specs(opts, aggopts[:metrics], ssh)
    # add children specs to the supervisor, that should spawn them
    |> populate_worker(opts)
  end

  # Add every child Wrapper to the Worker
  #
  defp populate_worker(specs, opts) do
    specs |> Enum.each(fn(spec)->
      res = Supervisor.start_child(opts[:name], spec)
      case res do
        {:ok, _} -> :ok
        {:ok, _, _} -> :ok
        other -> raise other
      end
    end)
  end

  # Loop indefinitely until an SSH connection is established with the target
  #
  defp loop_to_establish_ssh_connection(opts) do
    case establish_ssh_connection(opts) do
      {:ok, ssh} -> {:ok, ssh}
      {:error, reason} ->
        H.todo "Notify of failure reason"
        loop_to_establish_ssh_connection(opts)
    end
  end

  # Hide some param sanitizing needed by erlang's `:ssh`
  #
  defp establish_ssh_connection(opts) do
    target = opts[:data][:target] |> to_char_list
    user = opts[:data][:user] |> to_char_list

    H.env(:ssh_opts)
    |> Keyword.merge(user: user, ip: target)
    |> H.env(:ssh_module).connect
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
