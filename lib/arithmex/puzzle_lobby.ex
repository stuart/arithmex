defmodule Arithmex.PuzzleLobby do
  use GenServer
  import Supervisor.Spec

  def start_link do
    children = [worker(Arithmex.PuzzleServer, [], restart: :transient)]
    {:ok, sup_pid} = Supervisor.start_link(children, strategy: :simple_one_for_one)
    GenServer.start_link(__MODULE__, sup_pid, name: __MODULE__)
  end

  def init(sup_pid) do
    {:ok, {sup_pid, [], []}}
  end

  def request_join player do
    GenServer.call(__MODULE__, {:join_request, player})
  end

  def game_started game do
    GenServer.cast(__MODULE__, {:started, game})
  end

  def game_ended game do
    GenServer.cast(__MODULE__, {:ended, game})
  end

  def handle_call({:join_request, player}, _from, {sup, [], running}) do
    {:ok, game} = Supervisor.start_child(sup, [self])
    Arithmex.PuzzleServer.join(game, player)
    {:reply, {:ok, game}, {sup, [game], running}}
  end

  def handle_call({:join_request, player}, _from, {sup, waiting, running}) do
    [game | _] = waiting
    Arithmex.PuzzleServer.join(game, player)
    {:reply, {:ok, game}, {sup, waiting, running}}
  end

  def handle_cast({:started, game}, {sup, waiting, running}) do
    {:noreply, {sup, waiting -- [game], [game | running]}}
  end

  def handle_cast({:ended, game}, {sup, waiting, running}) do
    {:noreply, {sup, waiting, running -- [game]}}
  end
end
