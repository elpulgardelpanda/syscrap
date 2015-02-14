defmodule Syscrap.Reactor.Reaction do

  @moduledoc """
    The Reaction behaviour specification.
  """

  use Behaviour

  @doc """
    Start the main checking loop.
    Receives a Keyword list as passed from the Worker.
  """
  defcallback start_checking( list(Keyword) ) :: none

end
