ExUnit.start()

require Syscrap.Helpers, as: H

defmodule Syscrap.TestHelpers do

  ######
  # simple db helpers

  def get_coll(name \\ "test") do
    Mongo.connect!
    |> Mongo.db("syscrap")
    |> Mongo.Db.collection(name)
  end

  def insert(docs, collname \\ "test")
  def insert(docs, collname) when is_binary(collname) do
    coll = get_coll collname
    H.spit [docs, collname, coll]
    insert docs, coll
  end
  def insert(doc, coll) when is_map(doc) do
    H.spit [doc,coll]
    Mongo.Collection.insert_one(doc,coll)
  end
  def insert(docs, coll) when is_list(docs) do
    H.spit [docs,coll]
    for d <- docs, do: insert(d, coll)
  end

end
