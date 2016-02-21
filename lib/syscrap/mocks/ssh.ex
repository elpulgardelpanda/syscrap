alias Syscrap.Helpers.Metadata, as: HM

defmodule Syscrap.Mocks.SSHExAllOK do
  def connect(any) do
    HM.set_in( &(List.wrap(&1) ++ [%{args: any}]), [:test, SSHExAllOK, :connect])
    {:ok, :bogus}
  end
end
