alias Syscrap.Helpers.Metadata.Agent, as: MA
require Syscrap.Helpers, as: H

defmodule Syscrap.Helpers.Metadata do

  @moduledoc """
    Generic metadata helpers for saving and retrieving auxiliary state
    (supposed to be supported on maps).

    Every get/set function will call `start/0`, unless the `:no_start` option is given.
  """

  @doc """
    Update/insert given key/value into metadata agent's data
  """
  def set(v, k, opts \\ [])
  def set(func, key, opts) when is_function(func) do
    init(opts)
    Agent.update MA, fn(v)-> Map.update(v, key, func.(nil), func) end
  end
  def set(value, key, opts), do: set(fn(_)-> value end, key, opts)

  @doc """
    Update/insert given nested key/value into metadata agent's data
  """
  def set_in(value, keys, opts \\ []) do
    init(opts)
    Agent.update(MA, &H.set_in(&1, value, keys))
  end

  @doc """
    Update/insert given key/value into metadata agent's data, no waiting
  """
  def cast(value, key, opts \\ []) do
    init(opts)
    Agent.cast MA, &Map.update(&1,key,value,fn(_) -> value end)
  end

  @doc """
    Update/insert given nested key/value into metadata agent's data, no waiting
  """
  def cast_in(value, keys, opts \\ []) do
    init(opts)
    Agent.cast(MA, &H.set_in(&1, value, keys))
  end

  @doc """
    Get requested key from metadata agent's data. Given `default` if not found.
  """
  def at(key, default \\ nil, opts \\ []) do
    init(opts)
    Agent.get(MA, &(&1)) |> Map.get(key, default)
  end

  @doc """
    Get requested nested key from metadata agent's data. Given `default` if not found.
  """
  def at_in(keys, default \\ nil, opts \\ []) do
    init(opts)
    case Agent.get(MA, &(&1)) |> get_in(keys) do
      nil -> default
      v -> v
    end
  end

  @doc """
    Adds given element to a list on given coordinate.
    If any intermediate element is it is created as an empty map.
    If the final element is not a List, then it's wrapped into one (see List.wrap/1).
  """
  def add_in(elem, keys, opts \\ []) do
    set_in(&(List.wrap(&1) ++ [elem]), keys, opts)
  end

  @doc """
  Start the metadata agent if it's not already started.
  Only useful when `:no_start` is used on the get/set functions.

  Returns `:ok`, or `{:error, reason}`
  """
  def start do
    case Agent.start(fn-> %{} end, name: MA) do
      {:ok, _} -> :ok
      {:error, {:already_started, _}} -> :ok
      other -> other
    end
  end

  defp init(opts) do
    unless opts[:no_start], do: :ok = start
  end
end
