defmodule Syscrap.Notificator do
  use Supervisor

  @moduledoc """
    Main notification supervisor. It supervises a pool of
    `Notification.Worker` processes.
  """

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, [name: __MODULE__])
  end

  def init(opts) do
    alias Syscrap.Notificator.Notification, as: N

    # TODO: get pool size from config
    pool_size = 2

    children = for i <- (0..pool_size) do
      id = "Notificator.Worker.#{to_string(i)}" |> String.to_atom
      worker(Syscrap.Notificator.Worker, [[name: id]], [id: id])
    end

    supervise(children, strategy: :one_for_one, max_restarts: Enum.count(children) + 1)
  end
end
