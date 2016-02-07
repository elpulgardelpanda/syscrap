require Syscrap.Helpers, as: H
alias Mongo.Collection, as: MC

ExUnit.start()

defmodule Syscrap.TestHelpers do

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
