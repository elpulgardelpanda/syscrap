
defmodule Syscrap.Mocks.SSHExAllOK do
  def connect(_), do: {:ok, :bogus}
end
