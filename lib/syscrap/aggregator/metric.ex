defmodule Syscrap.Aggregator.Metric do

  @moduledoc """
    The Metric behaviour specification.
  """

  @doc """
    The main gathering loop.
    Receives a Keyword list as passed from the Worker.
  """
  @callback gather_loop( list(Keyword) ) :: none

end
