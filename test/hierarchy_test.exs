require Syscrap.Helpers, as: H
require Syscrap.TestHelpers, as: TH

defmodule HierarchyTest do
  use ExUnit.Case

  setup do
    TH.Db.drop ["targets", "reaction_targets", "aggregation_options"]
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
    # add some targets
    targets = [%{target: "1.1.1.1", user: "myuser"},
               %{target: "1.1.1.2", user: "myuser"},
               %{target: "1.1.1.3", user: "myuser"}]
    TH.Db.insert targets, "targets"

    # expected worker names
    workers = [:"Aggregator for 1.1.1.1",
               :"Aggregator for 1.1.1.2",
               :"Aggregator for 1.1.1.3"]

    # add some metrics for some targets
    aggopts = [%{target: "1.1.1.1", metrics: %{"Vitals.CPU": %{}}},
               %{target: "1.1.1.2", metrics: %{"Vitals.CPU": %{}, "Logs": %{}, "Traffic": %{}}}]
    TH.Db.insert aggopts, "aggregation_options"

    # expected wrapper names
    wrappers1 = [:"Vitals.CPU for 1.1.1.1"]
    wrappers2 = [:"Vitals.CPU for 1.1.1.2",
                 :"Logs for 1.1.1.2",
                 :"Traffic for 1.1.1.2" ]

    # check all workers are there
    check_supervisor Syscrap.Aggregator, workers

    # check all wrappers are there
    check_supervisor :"Aggregator for 1.1.1.1", wrappers1
    check_supervisor :"Aggregator for 1.1.1.2", wrappers2
    check_supervisor :"Aggregator for 1.1.1.3", []
  end

  test "Notificator hierarchy looks good" do
    check_supervisor Syscrap.Notificator, [], count: H.env(:notificator_worker_count)
  end

  test "Reactor hierarchy looks good" do
    reaction_targets = [%{reaction: "Range", target: "1.1.1.1"},
                        %{reaction: "Range", target: "1.1.1.2"},
                        %{reaction: "Range", target: "1.1.1.3"}]
    TH.Db.insert reaction_targets, "reaction_targets"

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
