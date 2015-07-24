require Syscrap.Helpers, as: H
require Syscrap.TestHelpers, as: TH

defmodule HierarchyTest do
  use ExUnit.Case

  test "Hierarchy looks good" do
    # look at main supervisor first
    check_supervisor Syscrap.Supervisor, [Syscrap.Aggregator,
                                  Syscrap.Notificator, Syscrap.Reactor,
                                  :mongo_pool, :syscrap_alive_loop]
  end

  test "Aggregator hierarchy looks good" do
    targets = [ %{target: "t1"},%{target: "t2"},%{target: "t3"} ]
    TH.insert targets, "targets"

    workers = for t <- targets, into: [], do:
      String.to_atom("Worker for " <> t.target)

    check_supervisor Syscrap.Aggregator, workers
  end

  test "Notificator hierarchy looks good" do
    # TODO: get notificator pool size from config
    check_supervisor Syscrap.Notificator, [:"Notificator.Worker.0",
                            :"Notificator.Worker.1", :"Notificator.Worker.2"]
  end

  test "Reactor hierarchy looks good" do
    # TODO: a way to get defined `reactions` ?
    check_supervisor Syscrap.Reactor,
                  [:"Worker for Elixir.Syscrap.Reactor.Reaction.Range"]
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

    # check named children are there again too
    H.wait_for fn -> named == H.named_children(supervisor) end
  end
end
