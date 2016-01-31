require Syscrap.Helpers, as: H

defmodule HierarchyTest do
  use ExUnit.Case

  setup do
    H.Db.drop "targets"
    :ok
  end

  test "Hierarchy looks good" do
    # look at main supervisor first
    check_supervisor Syscrap.Supervisor,
                     [Syscrap.Aggregator, Syscrap.AggregatorPopulator,
                      Syscrap.Reactor, Syscrap.ReactorPopulator,
                      Syscrap.Notificator, Syscrap.AliveLoop, Syscrap.MongoPool]
  end

  test "Aggregator hierarchy looks good" do
    targets = [%{target: "1.1.1.1"},
               %{target: "1.1.1.2"},
               %{target: "1.1.1.3"}]
    TH.insert targets, "targets"

    workers = for t <- targets, into: [], do:
      String.to_atom("Aggregator for " <> t.target)

    check_supervisor Syscrap.Aggregator, workers

    H.todo "Check Wrapper hierarchy too"
  end

  test "Notificator hierarchy looks good" do
    check_supervisor Syscrap.Notificator, [], count: H.env(:notificator_worker_count)
  end

  test "Reactor hierarchy looks good" do
    reaction_targets = [%{reaction: "Range",target: "1.1.1.1"},
                        %{reaction: "Range",target: "1.1.1.2"},
                        %{reaction: "Range",target: "1.1.1.3"}]
    TH.insert reaction_targets, "reaction_targets"

    workers = for t <- reaction_targets, into: [], do:
      String.to_atom(t.reaction <> " for " <> t.target)

    check_supervisor Syscrap.Reactor, workers
  end

  # Check every `named_children` is there.
  # Optional `count` to check for total count of children when not all are named.
  #
  defp check_supervisor(supervisor, named_children, opts \\ []) do

    opts = opts |> H.defaults(count: named_children |> Enum.count)

    # check every children is up
    H.wait_for fn ->
      opts[:count] == supervisor |> Supervisor.which_children |> Enum.count
    end

    # check all named children are there
    named = H.named_children(supervisor)
    for child <- named_children, do: assert child in named

  end
end
