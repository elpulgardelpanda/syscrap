defmodule Syscrap.Aggregator.Metric do
  use Behaviour

  @doc """
    Main gathering loop
    TODO: specify arguments' types, leaving it generic until it settles properly
  """
  defcallback start_gathering( list(Keyword) ) :: none

end
