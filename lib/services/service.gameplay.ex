defmodule ClusterChess.Services.Gameplay do

    use ClusterChess.Services.Default

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

    defp process("move.do", req, state) do
        notify_other_players(state)
        process("game.spectate", req, state)
    end

    defp process("move.undo", req, state) do
        notify_other_players(state)
        process("game.spectate", req, state)
    end

    defp process("game.draw", req, state) do
        notify_other_players(state)
        process("game.spectate", req, state)
    end

    defp process("game.resign", req, state) do
        notify_other_players(state)
        process("game.spectate", req, state)
    end

    defp process("game.spectate", req, state) do
        update = update_in(state.spectators, fn set ->
            {caller_pid, _tag} = req["from"]
            old = set || MapSet.new()
            expansion = MapSet.new([caller_pid])
            MapSet.union(old, expansion)
        end)
        {:reply, {:ok, "request.ack"}, update}
    end

end
