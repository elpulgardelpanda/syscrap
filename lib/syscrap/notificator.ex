defmodule Syscrap.Notificator do
  use GenServer

  @moduledoc """
    Process responsible for sending notifications.
  """

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [name: __MODULE__])
  end

  def init(opts) do

    # TODO: start notification loop

    {:ok, opts}
  end
end