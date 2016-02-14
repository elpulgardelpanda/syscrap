
defmodule Syscrap.Mocks.SSHAllOK do
  def connect(_,_,_,_), do: {:ok, :bogus}
end
