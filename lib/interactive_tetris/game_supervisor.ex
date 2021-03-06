defmodule InteractiveTetris.GameSupervisor do
  use Supervisor

  alias InteractiveTetris.Repo
  alias InteractiveTetris.Room

  def start_game(room_id) do
    room = Repo.get(Room, room_id)
    room = Repo.preload(room, [:connected_users])

    {:ok, pid} = Supervisor.start_child(__MODULE__, [room])
    pid
  end

  def update_game(room_id) do
    pid = InteractiveTetris.get_game_by_room_id(room_id)

    room = Repo.get(Room, room_id)
    room = Repo.preload(room, [:connected_users])

    InteractiveTetris.Game.update_room(pid, room)
  end

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(InteractiveTetris.Game, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
