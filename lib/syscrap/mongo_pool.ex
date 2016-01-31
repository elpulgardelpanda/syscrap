defmodule Syscrap.MongoPool do

  use Mongo.Pool, name: __MODULE__, adapter: Mongo.Pool.Poolboy,
                  size: H.env(:mongo_pool_opts)[:size],
                  max_overflow: H.env(:mongo_pool_opts)[:max_overflow]
end
