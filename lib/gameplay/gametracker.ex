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

    defp notify_other_players(state) do
        spectators = Map.get(state, :spectators, MapSet.new())
        Enum.each(spectators, fn spectator ->
            send(spectator, {:forward, Jason.encode!(state.board)})
        end)
    end

    defp register_spectator(req, state) do
        update = update_in(state.spectators, fn set ->
            {caller_pid, _tag} = req["from"]
            old = set || MapSet.new()
            expansion = MapSet.new([caller_pid])
            MapSet.union(old, expansion)
        end)
        {:reply, {:ok, "request.ack"}, update}
    end

    defp process(type, req, state) do
        register_spectator(req, state)
        if type != "game.spectate" do
            notify_other_players(state)
        end
        case type do
            _ -> {:reply, {:ok, "request.ack"}, state}
        end
    end
end
