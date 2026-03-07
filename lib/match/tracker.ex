defmodule Match.Tracker do

    @behaviour GenServer

    alias Match.DoMove
    alias Match.Draw
    alias Match.Resign
    alias Match.Persinstence

    @impl GenServer
    def init(%{raw: state}),
        do: {:ok, state}

    @impl GenServer
    def init(%{game: game}),
        do: {:ok, Persinstence.rehydrate(game)}

    @impl GenServer
    def handle_call(datapack, sender, state) do
        req = Map.merge(datapack, %{ :sender => sender })
        out = case Map.fetch(req, :type) do
            {:ok, "game.domove"  } -> DoMove.update_state(state, req)
            {:ok, "game.draw"    } -> Draw.update_state(state, req)
            {:ok, "game.resign"  } -> Resign.update_state(state, req)
            {:ok, "game.spectate"} -> {:ok, update_spectators(state, req.sender)}
            _unrecognized_msg_type -> {:error, "unrecognized_msg_type"}
        end
        with {:ok, new_state} <- out do
            Persinstence.sync(new_state)
            notify_spectators(new_state)
            {:reply, :ok, new_state}
        else
            :unchanged -> {:reply, :ok, state}
            err -> {:reply, err, state}
        end
    end

    defp notify_spectators(state) do
        spectators = state.players.spectators
        Enum.each(spectators, fn spectator ->
            send(spectator, {:game_update, state})
        end)
    end

    defp update_spectators(state, {sender_pid, _ref}) do
        update_in(state.players.spectators, fn set ->
            old = set || MapSet.new()
            expansion = MapSet.new([sender_pid])
            MapSet.union(old, expansion)
        end)
    end
end
