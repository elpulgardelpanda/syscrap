require Syscrap.Helpers, as: H

defmodule Syscrap.Reactor do
  use Supervisor

  @moduledoc """
    Main reaction supervisor. It spawns and supervises one
    `Reactor.Worker` for each `ReactionTarget` defined on db.
  """

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, [name: __MODULE__])
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
    # H.spit H.Db.find("reaction_targets")
    H.Db.find("reaction_targets")
  end

  @doc """
    Populator child_spec function
  """
  def child_spec(data, _) do
    args = [data: data,
            name: String.to_atom("#{data[:reaction]} for #{data[:target]}"),
            reaction: get_reaction_module(data[:reaction])]

    supervisor(Syscrap.Reactor.Worker, [args], [id: args[:name]])
  end

  # Get the actual `Reaction` module from given string,
  # or else return `Syscrap.Reactor.Reaction.Undefined` and log the issue.
  #
  defp get_reaction_module(reaction) do
    try do
      String.to_existing_atom "Elixir.Syscrap.Reactor.Reaction.#{reaction}"
    rescue
      ArgumentError -> Syscrap.Reactor.Reaction.Undefined
    end
  end

end
