alias Syscrap.Helpers.Metadata, as: HM

defmodule Syscrap.Mocks.SSHExAllOK do
  def connect(any) do
    %{args: any} |> HM.add_in([:test, SSHExAllOK, :connect])
    {:ok, :bogus}
  end
end
