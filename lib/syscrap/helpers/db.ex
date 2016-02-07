require Syscrap.Helpers, as: H
alias Mongo.Collection, as: MC
alias Syscrap.MongoWorker, as: MW

defmodule Syscrap.Helpers.Db do

  @moduledoc """
    Shortcuts for usual db operations using the app's pool.

    See `Syscrap.MongoWorker.run/2`.
  """


  @doc """
    Simple find query. Returns a list.

    ```
      targets = H.Db.find("targets")
      targets = H.Db.find("targets", %{"ip": "1.2.3.4"})
    ```
  """
  def find(coll, selector, opts \\ []) when is_binary(coll) and is_map(selector) do
    opts |> Keyword.merge(coll: coll, selector: selector) |> find
  end
  def find(coll) when is_binary(coll), do: find(coll, %{})
  def find(opts) do
    opts = H.defaults opts, db: H.env(:mongo_db_opts)[:database],
                            coll: "test",
                            pool: Syscrap.MongoPool,
                            selector: %{},
                            projector: %{}

    MW.run opts, fn(coll)->
      MC.find(coll, opts[:selector], opts[:projector]) |> Enum.to_list
    end
  end

  @doc """
    Perform an insert operation.

    ```
      [%{a: 1},%{a: 2}] |> H.Db.insert("targets")
      %{a: 3} |> H.Db.insert("targets")
    ```
  """
  def insert(docs, coll, opts \\ [])
  def insert(doc, coll, opts) when is_map(doc), do: insert([doc], coll, opts)
  def insert([], _, _), do: :ok
  def insert(docs, coll, opts) when is_list(docs),
    do: opts |> Keyword.merge(docs: docs, coll: coll) |> insert

  def insert(opts) do
    opts = H.defaults opts, db: H.env(:mongo_db_opts)[:database],
                            coll: "test",
                            pool: Syscrap.MongoPool

    MW.run opts, fn(coll)-> MC.insert(opts[:docs], coll) end
  end

end
