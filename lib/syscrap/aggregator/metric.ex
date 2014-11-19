defmodule Syscrap.Aggregator.Metric do

  @moduledoc """
    The Metric behaviour specification.
  """

  use Behaviour

  @doc """
    Main gathering loop.
    Receives a Keyword list as passed from the Worker.
  """
  defcallback start_gathering( list(Keyword) ) :: none

end
