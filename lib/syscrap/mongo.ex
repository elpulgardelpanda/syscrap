defmodule Syscrap.Mongo do
  use GenServer

  @moduledoc """
    This worker encapsulates a Mongo connection pooled using `:poolboy`.
    No more, no less.

    Well, maybe a little more.

    It includes some helpers to ease the work with that connection, assuming
    that `:poolboy`'s named pool is `:mongo_pool` by default.

    ## Usage

    ### Using `get/1` & `release/1`

    Use `get/1` to get a `Mongo.Collection` record and a reference to its
    worker on the pool. Then perform any operation on that collection.

    Remember to call `release/1` to return the worker to the pool. Once you
    are done with it.

    `iex` session:

    ```
    iex(1)> alias Syscrap.Mongo, as: SM
    iex(2)> alias Mongo.Collection, as: MC
    iex(3)> :poolboy.status(:mongo_pool)
    {:ready, 5, 0, 0}
    iex(4)> {coll, worker} = SM.get db: "syscrap", coll: "test"

    iex(6)> MC.find(coll) |> Enum.to_list
    [%{_id: ObjectId(5468f42a4f9bdc79d2779e9a), a: 23},
    %{_id: ObjectId(5468fb834f9bdc79d2779e9b), b: 23235}]

    iex(7)> %{c: "blabla"} |> MC.insert_one(coll)
    {:ok, %{c: "blabla"}}

    iex(8)> MC.find(coll) |> Enum.to_list
    [%{_id: ObjectId(5468f42a4f9bdc79d2779e9a), a: 23},
    %{_id: ObjectId(5468fb834f9bdc79d2779e9b), b: 23235},
    %{_id: ObjectId(5468fee64f9bdc79d2779e9c), c: "blabla"}]

    iex(9)> :poolboy.status(:mongo_pool)
    {:ready, 4, 0, 1}
    iex(10)> SM.release worker
    :ok
    iex(11)> :poolboy.status(:mongo_pool)
    {:ready, 5, 0, 0}

    ```

    ### Using `transaction`

    TODO

  """

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
    Creates the connection for this worker.
    `opts` will be used when needed. By now there's no need.
  """
  def init(_opts) do
    {:ok, Mongo.connect!}
  end

  @doc """
    Yield the connection when asked
  """
  def handle_call(:yield, _from, conn) do
    {:reply, conn, conn}
  end

  @doc """
    Request the connection to the worker, and get db/collection for given names.
  """
  def yield(server, [db: db, coll: coll]) do
    GenServer.call(server, :yield)
    |> Mongo.db(db)
    |> Mongo.Db.collection(coll)
  end

  @doc """
    Get db/collection for given names using a worker from given pool
    (`:mongo_pool` by default).
    Returns requested Mongo collection, and the underlying worker.
    You should checkin that worker back to the pool using `release/1`.
  """
  def get([db: db, coll: coll]), do: get(db: db, coll: coll, pool: :mongo_pool)
  def get([db: db, coll: coll, pool: pool]) do
    w = :poolboy.checkout(pool)
    coll = w |> yield db: db, coll: coll
    {coll,w}
  end

  @doc """
    Checkin given worker to given pool (`:mongo_pool` by default).
  """
  def release(worker, pool \\ :mongo_pool), do: :poolboy.checkin(pool, worker)

end
