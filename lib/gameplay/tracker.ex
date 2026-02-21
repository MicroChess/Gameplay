defmodule KubeChess.Gameplay.Tracker do

    use KubeChess.Commons.Service
    alias KubeChess.Gameplay.State

    @impl GenServer
    def handle_call(datapack, sender, state) do
        request = Map.merge(datapack, %{ :sender => sender })
        case Map.fetch(request, :type) do
            {:ok, mtype} -> process(mtype, request, state)
            _ -> {:reply, :fatal, state}
        end
    end

    def notify_spectators(state) do
        players = Map.get(state, :players, Map.new())
        spectators = Map.get(players, :spectators, MapSet.new())
        Enum.each(spectators, fn spectator ->
            send(spectator, {:game_update, state})
        end)
    end

    def update_spectators(state, {pid, _ref}),
        do: update_spectators(state, pid)

    def update_spectators(state, from) do
        update_in(state.players.spectators, fn set ->
            old = set || MapSet.new()
            expansion = MapSet.new([from])
            MapSet.union(old, expansion)
        end)
    end

    defp process(type, req, state) do
        state = update_spectators(state, req.sender)
        {white, black} = {state.players.white, state.players.black}
        turn = if state.board.turn == :white,
            do: state.players.white,
            else: state.players.black
        out = case {req.uid, type} do
            {^turn, "game.domove"}  -> State.apply_move(state, req)
            {^white, "game.draw"}   -> State.apply_draw(state, req)
            {^white, "game.resign"} -> State.apply_resign(state, req)
            {^black, "game.draw"}   -> State.apply_draw(state, req)
            {^black, "game.resign"} -> State.apply_resign(state, req)
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
end
