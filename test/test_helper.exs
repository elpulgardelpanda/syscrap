require Syscrap.Helpers, as: H
alias Mongo.Collection, as: MC
require ExUnit.Assertions, as: A

ExUnit.start()


defmodule Syscrap.TestHelpers do

  @moduledoc """
    Some custom assertions
  """

  @doc """
    Assert that every element of the first list evaluates the given func to true
    when combined with at least one element on the second list.

    ## Example:

      a = [1,2,3,4]
      b = [2,4,6,8]
      a |> assert_any(b, &( 2*&1 == &2 )) # ok
  """
  def assert_any(list1, list2, func) do
    Enum.each(list1, fn(e1)->
        A.assert Enum.any?(list2, fn(e2)->
          func.(e1, e2)
        end), "#{inspect e1} did not assert against #{inspect list2}"
    end)
  end

end


defmodule Syscrap.TestHelpers.Db do

  @moduledoc """
    Shortcuts for usual db operations on test, independent from application's pool
  """

  @doc """
    * `docs` can be a list of maps or a single `Map`
    * `collname` must be a binary with the name of the collection
  """
  def insert(docs, collname) when is_binary(collname) do
    coll = get_coll collname
    do_insert docs, coll
  end

  defp do_insert(docs, coll) when is_list(docs), do: MC.insert(docs, coll)
  defp do_insert(doc, coll) when is_map(doc), do: MC.insert_one(doc,coll)

  @doc """
    * `collname` must be a binary with the name of the collection
  """
  def drop(colls) when is_list(colls),
    do: colls |> Enum.each(&drop/1)
  def drop(collname),
    do: collname |> get_coll |> MC.drop

  defp get_coll(name) do
    dbname = H.env(:mongo_db_opts)[:database]

    Mongo.connect!
    |> Mongo.db(dbname)
    |> Mongo.Db.collection(name)
  end

end
