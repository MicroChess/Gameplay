defmodule Tracker do

    use GenServer

    @impl GenServer
    def init(%{raw: game}),
        do: {:ok, %{ game: game, ping: Process.send_after(self(), :ping, 0) }}

    @impl GenServer
    def init(%{game_id: game_id}) do
        game = Persinstence.rehydrate(game_id)
        milliseconds = Clock.milliseconds_on_the_clock(game, game.board.turn)
        ping = Process.send_after(self(), :ping, milliseconds)
        {:ok, %{ game: game, ping: ping }}
    end

    @impl GenServer
    def handle_info(:ping, %{game: game, ping: _old_ping}) do
        Spectate.notify_spectators(game)
        if game.ending.winner == nil and !Clock.game_timed_out?(game) do
            milliseconds = Clock.milliseconds_on_the_clock(game, game.board.turn)
            new_ping = Process.send_after(self(), :ping, milliseconds)
            {:noreply, %{ game: game, ping: new_ping }}
        end
    end

    @impl GenServer
    def handle_call(%{type: type, body: body}, sender, state) do
        out = case type do
            "domove"   -> DoMove.update_state(state.game, body)
            "draw"     -> Draw.update_state(state.game, body)
            "resign"   -> Resign.update_state(state.game, body)
            "undo"     -> Undo.update_state(state.game, body)
            "spectate" -> Spectate.update_state(state.game, sender)
            _unknown   -> {:error, "unrecognized_msg_type"}
        end
        with {:ok, game} <- out do
            Process.cancel_timer(state.ping)
            new_state = %{game: game, ping: state.ping}
            handle_info(:ping, new_state)
            {:reply, :ok, new_state}
        else
            :unchanged -> {:reply, :ok, state}
            err -> {:reply, err, state}
        end
    end
end
