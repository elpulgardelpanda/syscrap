ExUnit.start()

defmodule Syscrap.TestHelpers do

  ######
  # simple db helpers

  def get_coll(name \\ "test") do
    Mongo.connect!
    |> Mongo.db("syscrap")
    |> Mongo.Db.collection(name)
  end

  def insert(docs, collname) when is_binary(collname) do
    coll = get_coll collname
    insert docs, coll
  end
  def insert(docs, coll) when is_list(docs) do
    for d <- docs, do: insert(d, coll)
  end
  def insert(doc, coll) when is_map(doc), do: Mongo.Collection.insert_one(doc,coll)

  def drop(collname), do: collname |> get_coll |> Mongo.Collection.drop

end
