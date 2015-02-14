require Logger, as: L

defmodule Syscrap.Helpers do

  @doc """
    Convenience to get environment bits. Avoid all that repetitive
    `Application.get_env( :myapp, :blah, :blah)` noise.
  """
  def env(key, default), do: env(:syscrap, key, default)
  def env(app, key, default \\ nil), do: Application.get_env(app, key, default)

  @doc """
    Spit to logger, with proper margin and colors.
    If you pass the `__ENV__` it will also print the location.

    ```
      Helpers.spit my_mystery_object, __ENV__
    ```
  """
  def spit(obj, caller \\ nil) do
    loc = case caller do
      %{file: file, line: line} -> "\n\n#{file}:#{line}"
      _ -> ""
    end
    "#{loc}\n\n#{inspect obj}\n\n" |> L.debug
  end
end

