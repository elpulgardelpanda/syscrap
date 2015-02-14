defmodule Syscrap.Notificator.Notification do

  @moduledoc """
    The Notification behaviour specification.
  """

  use Behaviour

  @doc """
    Start the main notifying loop.
    Receives a Keyword list as passed from the Worker.
  """
  defcallback run( list(Keyword) ) :: none

end
