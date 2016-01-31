alias Syscrap.MongoPool, as: P
alias Mongo, as: M

defmodule Syscrap.Helpers.Db do

  @moduledoc """
    Shortcuts for usual db operations
  """

  def find(coll, filter \\ %{}, opts \\ []),
    do: M.find(P, coll, filter, opts) |> Enum.to_list

  def count(coll, filter \\ %{}, opts \\ []),
    do: M.count(P, coll, filter, opts)

  def delete_many(coll, filter \\ %{}, opts \\ []),
    do: M.delete_many(P, coll, filter, opts)

  def drop(coll), do: delete_many(coll)

end
