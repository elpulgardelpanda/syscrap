alias Syscrap.Helpers.Metadata, as: HM

defmodule Syscrap.Mocks.SSHExAllOK do
  def connect(_), do: {:ok, :bogus}
end
