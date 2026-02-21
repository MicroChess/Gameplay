defmodule KubeChess.Match.Tracker do

    @behaviour GenServer

    alias KubeChess.Match.DoMove
    alias KubeChess.Match.Draw
    alias KubeChess.Match.Resign

    @impl GenServer
    def init(state) do
        {:ok, state}
    end

    @impl GenServer
    def handle_call(datapack, sender, state) do
        request = Map.merge(datapack, %{ :sender => sender })
        case Map.fetch(request, :type) do
            {:ok, mtype} -> process(mtype, request, state)
            _ -> {:reply, :fatal, state}
        end
    end

    defp process(type, req, state) do
        state = update_spectators(state, req.sender)
        {white, black} = {state.players.white, state.players.black}
        turn = if state.board.turn == :white,
            do: state.players.white,
            else: state.players.black
        out = case {req.uid, type} do
            {^turn, "game.domove"}  -> DoMove.apply_move(state, req)
            {^white, "game.draw"}   -> Draw.apply_draw(state, req)
            {^white, "game.resign"} -> Resign.apply_resign(state, req)
            {^black, "game.draw"}   -> Draw.apply_draw(state, req)
            {^black, "game.resign"} -> Resign.apply_resign(state, req)
            {_any, "game.spectate"} -> {:ok, state}
            _unrecognized_msg_type  -> {:error, "unrecognized_msg_type"}
        end
        with {:ok, new_state} <- out do
            notify_spectators(new_state)
            {:reply, :ok, new_state}
        else
            err -> {:reply, err, state}
        end
    end

    defp notify_spectators(state) do
        players = Map.get(state, :players, Map.new())
        spectators = Map.get(players, :spectators, MapSet.new())
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
