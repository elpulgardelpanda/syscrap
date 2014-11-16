defmodule Syscrap.MongoConnection do
  use GenServer

  @moduledoc """
    This worker encapsulates a Mongo connection. No more, no less.
  """

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
    Creates the connection for this worker.
    `opts` will be used when needed. By now there's no need.
  """
  def init(_opts) do
    {:ok, Mongo.connect!}
  end

  @doc """
    Yield the connection when asked
  """
  def handle_call(:yield, _from, conn) do
    {:reply, conn, conn}
  end

  @doc """
    Request the connection
  """
  def yield(server) do
    GenServer.call(server, :yield)
  end

end
