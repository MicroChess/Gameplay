defmodule ClusterChess.Gameplay.Tracker do

    use ClusterChess.Commons.Service
    alias ClusterChess.Gameplay.Validation

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
        {white, black} = {state.white_player, state.black_player}
        turn = if state.turn == :white,
            do: state.white_player,
            else: state.black_player
        out = case {req["uid"], type} do
            {^turn, "game.domove"}  -> handle_move(req, state)
            {^white, "game.undo"}   -> handle_undo(req, state)
            {^white, "game.draw"}   -> handle_draw(req, state)
            {^white, "game.resign"} -> handle_resign(req, state)
            {^black, "game.undo"}   -> handle_undo(req, state)
            {^black, "game.draw"}   -> handle_draw(req, state)
            {^black, "game.resign"} -> handle_resign(req, state)
            {_any, "game.spectate"} -> handle_spectate(req, state)
            _unrecognized_msg_type  -> {:fatal, "unrecognized msg"}
        end
        with {:ok, new_state} <- out do
            notify_spectators(new_state)
            {:reply, :ok, new_state}
        else
            err -> {:reply, err, state}
        end
    end

    defp handle_move(req, state) do
        after_move = state.board
            |> Map.put(req.to, Map.get(state.board, req.from))
            |> Map.delete(req.from)
        new_turn = if state.turn == state.white_player,
            do: state.black_player,
            else: state.white_player
        case Validation.validate_move(state.board, req.from, req.to) do
            true -> {:ok, %{state | board: after_move, turn: new_turn}}
            {:error, reason} -> {:fatal, reason}
        end
    end

    defp handle_undo(_req, state) do
        {:ok, state}
    end

    defp handle_draw(_req, state) do
        {:ok, state}
    end

    defp handle_resign(_req, state) do
        {:ok, state}
    end

    defp handle_spectate(_req, state) do
        {:ok, state}
    end
end
