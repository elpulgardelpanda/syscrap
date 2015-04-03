require Logger, as: L

defmodule Syscrap.Helpers do

  @doc """
    Convenience to get environment bits. Avoid all that repetitive
    `Application.get_env( :myapp, :blah, :blah)` noise.
  """
  def env(key, default \\ nil), do: env(:syscrap, key, default)
  def env(app, key, default), do: Application.get_env(app, key, default)

  @doc """
    Spit to logger any passed variable, with location information.
  """
  defmacro spit(obj, inspect_opts \\ []) do
    quote do
      %{file: file, line: line} = __ENV__
      [ :bright, :red, "\n\n#{file}:#{line}",
        :normal, "\n\n#{inspect(unquote(obj),unquote(inspect_opts))}\n\n", :reset]
      |> IO.ANSI.format(true) |> IO.puts
    end
  end

  @doc """
    Print to stdout a _TODO_ message, with location information.
  """
  defmacro todo(msg \\ "") do
    quote do
      %{file: file, line: line} = __ENV__
      [ :yellow, "\nTODO: #{file}:#{line} #{unquote(msg)}\n", :reset]
      |> IO.ANSI.format(true) |> IO.puts
    end
  end

  @doc """
    Gets names for children in given supervisor. Children with no registered
    name are not returned. List is sorted.
  """
  def named_children(supervisor) do
    supervisor
      |> Supervisor.which_children
      |> Enum.map(fn({_,pid,_,_})-> Process.info(pid)[:registered_name] end)
      |> Enum.filter(&(&1))
      |> Enum.sort
  end

end
