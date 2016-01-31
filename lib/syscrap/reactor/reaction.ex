defmodule Syscrap.Reactor.Reaction do

  @moduledoc """
    The Reaction behaviour specification.
  """

  @doc """
    The main checking loop.
    Receives a Keyword list as passed from the Worker.
  """
  @callback check_loop( list(Keyword) ) :: none

end
