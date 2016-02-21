alias Syscrap.Helpers.Metadata.Agent, as: MA
alias Syscrap.Helpers, as: H

defmodule Syscrap.Helpers.Metadata do

  @moduledoc """
    Generic metadata helpers for saving and retrieving auxiliary state
    (supposed to be supported on maps)
  """

  @doc """
    Start the metadata agent if it's not already started
  """
  def init do
    case Agent.start(fn-> %{} end, name: MA) do
      {:ok, _} -> :ok
      {:error, {:already_started, _}} -> :ok
      other -> other
    end
  end

  @doc """
    Update/insert given key/value into mock_agent's data
  """
  def set(value, key, opts \\ []) do
    if not opts[:no_init], do: :ok = init
    Agent.update MA, &Map.update(&1,key,value,fn(_) -> value end)
  end

  @doc """
    Update/insert given nested key/value into mock_agent's data
  """
  def set_in(value, keys, opts \\ []) do
    if not opts[:no_init], do: :ok = init
    Agent.update(MA, &H.set_in(&1, value, keys))
  end

  @doc """
    Update/insert given key/value into mock_agent's data, no waiting
  """
  def cast(value, key, opts \\ []) do
    if not opts[:no_init], do: :ok = init
    Agent.cast MA, &Map.update(&1,key,value,fn(_) -> value end)
  end

  @doc """
    Update/insert given nested key/value into mock_agent's data, no waiting
  """
  def cast_in(value, keys, opts \\ []) do
    if not opts[:no_init], do: :ok = init
    Agent.cast(MA, &H.set_in(&1, value, keys))
  end

  @doc """
    Get requested key from mock_agent's data. Given `default` if not found.
  """
  def at(key, default \\ nil, opts \\ []) do
    if not opts[:no_init], do: :ok = init
    Agent.get(MA, &(&1)) |> Map.get(key, default)
  end

  @doc """
    Get requested nested key from mock_agent's data. Given `default` if not found.
  """
  def at_in(keys, default \\ nil, opts \\ []) do
    if not opts[:no_init], do: :ok = init
    case Agent.get(MA, &(&1)) |> get_in(keys) do
      nil -> default
      v -> v
    end
  end
end
