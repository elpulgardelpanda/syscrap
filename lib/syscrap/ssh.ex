defmodule Syscrap.SSH do

  @moduledoc """
    Module to deal with SSH connections. It uses low level erlang
    [ssh library](http://www.erlang.org/doc/man/ssh.html).
  """

  @doc """
    Gets an open SSH connection reference (as returned by `:ssh.connect/4`),
    and a command to execute.

    Optionally it gets a timeout for the underlying SSH channel opening,
    and for the execution itself.

    Any failure related with the SSH connection itself is raised without mercy.
  """
  def run(conn, cmd, channel_timeout \\ :infinity, exec_timeout \\ :infinity) do
    conn
    |> open_channel(channel_timeout)
    |> exec(conn, cmd, exec_timeout)
    |> get_response
  end

  # Try to get the channel, raise if it's not working
  #
  defp open_channel(conn, channel_timeout) do
    res = :ssh_connection.session_channel(conn, channel_timeout)
    case res do
      { :error, reason } -> raise reason
    end
    { :ok, channel } = res
    channel
  end

  # Execute the given command, raise if it fails
  #
  defp exec(channel, conn, cmd, exec_timeout) do
    res = :ssh_connection.exec(conn, channel, cmd, exec_timeout)
    case res do
      :failure -> raise "Could not exec #{cmd}!"
    end
    channel
  end

  # Loop until all data is received. Return read data and the exit_status.
  #
  defp get_response(channel, data \\ "", status \\ nil) do
    receive do
      {:data, ^channel, _, new_data} -> get_response(channel, data <> new_data)
      {:eof, ^channel} -> get_response(channel, data)
      {:exit_signal, ^channel, _, _} -> get_response(channel, data)
      {:exit_status, ^channel, status} -> get_response(channel, data, status)
      {:closed, ^channel} -> { data, status }
    end
  end

end
