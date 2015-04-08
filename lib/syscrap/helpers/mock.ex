
defmodule Syscrap.Helpers.Mock do

  @doc """
    Update/insert given key/value into mock_agent's data
  """
  def set(value, key) do
    Agent.update :syscrap_mock_agent, &Map.update(&1,key,value,fn(_) -> value end)
  end

  @doc """
    Get requested key from mock_agent's data. Given `default` if not found.
  """
  def get(key, default \\ nil) do
    Agent.get(:syscrap_mock_agent, &(&1)) |> Map.get(key, default)
  end

end
