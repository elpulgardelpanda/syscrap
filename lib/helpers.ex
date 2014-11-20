require Logger, as: L

defmodule Helpers do

  @doc """
    Spit to logger, with proper margin and colors.
    If you pass the `__ENV__` it will also print the location.

    ```
      Helpers.spit my_mystery_object, __ENV__
    ```
  """
  def spit(obj, caller \\ nil) do
    loc = case caller do
      nil -> ""
      %{file: file, line: line} -> "\n\n#{file}:#{line}"
    end
    "#{loc}\n\n#{inspect obj}\n\n" |> L.debug
  end

end

