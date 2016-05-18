defmodule Arithmex.Player.Server do
  use GenServer

  def start_link(player) do
    GenServer.start_link(__MODULE__, player)
  end

  def init(player) do
    {:ok, %{player: player, score: 0, expression: ""}}
  end

  def game_started pid, game do
    GenServer.cast(pid, {:game_started, game})
  end

  def game_ended pid, game do
    GenServer.cast(pid, {:game_ended, game})
  end

  def handle_call {:game_started, game}, _from, state do
    {:reply, :ok, state}
  end

  def handle_call {:game_ended, game}, _from, state do
    {:reply, :ok, state}
  end
end
