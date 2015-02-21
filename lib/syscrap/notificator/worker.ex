defmodule Syscrap.Notificator.Worker do
  use GenServer

  @moduledoc """
    Process responsible for comsuming notification from the queue.
  """

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [name: opts[:name]])
  end

  def init(opts) do

    # TODO: start notifying_loop

    {:ok, opts}
  end

  defp notifying_loop do
    # TODO: pop next notification from queue, pick the right
    # `Notification` module, and run it
    
    # DB: FINDandMODIFY first pending or stranded Notification
    # DB: FIND NotificationOptions for a target,type
    # DB: DELETE Notification
  end

end
