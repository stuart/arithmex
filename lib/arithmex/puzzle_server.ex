
defmodule Arithmex.PuzzleServer.Config do
  defstruct join_timeout: 30000, game_timeout: 30000, max_players: 5
end

defmodule Arithmex.PuzzleServer do
  use GenServer

  defstruct lobby: nil, puzzle: nil, players: [], status: :waiting, config: %__MODULE__.Config{}

  def start_link(lobby) do
    {:ok, pid} = GenServer.start_link __MODULE__, %__MODULE__{lobby: lobby}
  end

  def init(state) do
    Process.send_after(self(), :join_timeout, 30000)
    {:ok, state}
  end

  def players(pid) do
    GenServer.call(pid, :players)
  end

  def join(pid, player) do
    GenServer.call(pid, {:join, player})
  end

  def handle_call :players, _from, state do
    {:reply, state.players, state}
  end

  def handle_call({:join, player}, _from, state = %__MODULE__{players: players,
                                                              config: %__MODULE__.Config{max_players: max_players}})
  when length(players) < max_players do
    case state.status do
      :waiting -> {:reply, :ok, %__MODULE__{state | players: [player | state.players]}}
      :playing -> {:reply, :already_started, state}
      :ended -> {:reply, :game_over, state}
    end
  end

  def handle_call {:join, player}, _from, state do
    {:reply, :full, state}
  end

  def handle_info :join_timeout, state = %__MODULE__{players: [], status: :waiting, config: config} do
    Process.send_after(self(), :join_timeout, config.join_timeout)
    {:noreply, %{state | status: :waiting}}
  end

  def handle_info :join_timeout, state = %__MODULE__{lobby: lobby, status: :waiting, config: config} do
    Arithmex.PuzzleLobby.game_started(self)
    Process.send_after(self(), :game_timeout, config.game_timeout)
    {:noreply, %{state | status: :playing}}
  end

  def handle_info :game_timeout, state do
    # Send end message to players
    IO.puts "Ended"
    Arithmex.PuzzleLobby.game_ended(self)
    Enum.each state.players, fn(player) ->
      Arithmex.Player.Server.game_ended(player, self)
    end
    {:stop, :normal, %{state | status: :ended}}
  end
end
