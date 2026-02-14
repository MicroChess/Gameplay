defmodule ClusterChess.Gameplay.Tracker do

    use ClusterChess.Commons.Service
    alias ClusterChess.Gameplay.State

    @impl GenServer
    def handle_call(datapack, from, state) do
        request = Map.merge(datapack, %{ "from" => from })
        case Map.fetch(request, "type") do
            {:ok, mtype} -> process(mtype, request, state)
            _ -> {:reply, :fatal, state}
        end
    end

    def notify_spectators(state) do
        spectators = Map.get(state, :spectators, MapSet.new())
        Enum.each(spectators, fn spectator ->
            send(spectator, {:forward, Jason.encode!(state.squares)})
        end)
    end

    defp process(type, req, state) do
        state = State.update_spectators(state, req["from"])
        {white, black} = {state.white_player, state.black_player}
        turn = if state.board.turn == :white,
            do: state.white_player,
            else: state.black_player
        out = case {req["uid"], type} do
            {^turn, "game.domove"}  -> State.apply_move(state, req)
            {^white, "game.undo"}   -> State.apply_undo(state, req)
            {^white, "game.draw"}   -> State.apply_draw(state, req)
            {^white, "game.resign"} -> State.apply_resign(state, req)
            {^black, "game.undo"}   -> State.apply_undo(state, req)
            {^black, "game.draw"}   -> State.apply_draw(state, req)
            {^black, "game.resign"} -> State.apply_resign(state, req)
            {_any, "game.spectate"} -> {:ok, req["uid"]}
            _unrecognized_msg_type  -> {:fatal, "unrecognized msg"}
        end
        with {:ok, new_state} <- out do
            notify_spectators(new_state)
            {:reply, :ok, new_state}
        else
            err -> {:reply, err, state}
        end
    end
end
