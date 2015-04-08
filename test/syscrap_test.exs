require Syscrap.Helpers, as: H

defmodule SyscrapTest do
  use ExUnit.Case

  test "Hierarchy looks good" do
    # look at main supervisor first
    check_supervisor Syscrap.Supervisor, [Syscrap.Aggregator,
                                  Syscrap.Notificator, Syscrap.Reactor,
                                  :mongo_pool, :syscrap_alive_loop]

  end

  # Check given supervisor works.
  # Check every `known_children` is there. Then kill all its children
  # and check they are replaced with new ones.
  #
  # Note that `max_restarts` must be greater than the total number
  # of children under the supervisor, or this will fail.
  #
  defp check_supervisor(supervisor, known_children \\ []) do

    # check named children are there
    named = H.named_children(supervisor)
    for child <- known_children, do: assert child in named

    # get every child
    kids_count = supervisor |> Supervisor.which_children |> Enum.count

    # kill em all
    :ok = H.kill_children supervisor

    # grows up new children
    H.wait_for fn ->
      kids_count == supervisor |> Supervisor.which_children |> Enum.count
    end

    # check named children are there too
    for child <- known_children, do: assert child in named
  end
end
