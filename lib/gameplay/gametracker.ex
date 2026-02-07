defmodule ClusterChess.Gameplay.Tracker do

    use ClusterChess.Commons.Service

    @impl GenServer
    def handle_call(datapack, from, state) do
        request = Map.merge(datapack, %{ "from" => from })
        case Map.fetch(request, "type") do
            {:ok, mtype} -> process(mtype, request, state)
            _ -> {:reply, :fatal, state}
        end
    end

    defp notify_spectators(state) do
        spectators = Map.get(state, :spectators, MapSet.new())
        Enum.each(spectators, fn spectator ->
            send(spectator, {:forward, Jason.encode!(state.board)})
        end)
    end

    defp update_spectators(state, from) do
        update_in(state.spectators, fn set ->
            old = set || MapSet.new()
            expansion = MapSet.new([from])
            MapSet.union(old, expansion)
        end)
    end

    defp process(type, req, state) do
        state = update_spectators(state, req["from"])
        if type != "game.spectate" do
            notify_spectators(state)
        end
        case type do
            "game.domove"   -> handle_move(req, state)
            "game.undo"     -> handle_undo(req, state)
            "game.draw"     -> handle_draw(req, state)
            "game.resign"   -> handle_resign(req, state)
            "game.spectate" -> handle_spectate(req, state)
            _something_else -> {:reply, :fatal, state}
        end
    end

    defp handle_move(_req, state) do
        {:reply, {:ok, "game.domove.ack"}, state}
    end

    defp handle_undo(_req, state) do
        {:reply, {:ok, "game.undo.ack"}, state}
    end

    defp handle_draw(_req, state) do
        {:reply, {:ok, "game.draw.ack"}, state}
    end

    defp handle_resign(_req, state) do
        {:reply, {:ok, "game.resign.ack"}, state}
    end

    defp handle_spectate(_req, state) do
        {:reply, {:ok, "game.spectate.ack"}, state}
    end
end
