defmodule ClusterChess.Rules.PawnMoves do

    alias ClusterChess.Rules.Utilities

    def valid_move?(state, from, to),
        do: valid_single_push?(state, from, to)
        or  valid_double_push?(state, from, to)
        or  valid_capture?(state, from, to)
        or  valid_en_passant?(state, from, to)

    def valid_single_push?(state, from, to),
        do: increment(state, from, {0, 1}) == to

    def valid_double_push?(state, from, to),
        do: increment(state, from, {0, 2}) == to
        and starting_rank?(state, from)

    def valid_capture?(state, from, to),
        do: (increment(state, from, {1, 1}) == to
        or  increment(state, from, {-1, 1}) == to)
        and Utilities.color(state.board, to)
        not in [nil, Utilities.color(state.board, from)]


    def valid_en_passant?(_state, _from, _to) do
        false
    end

    defp increment(state, {f, r}, {x, y}) do
        case Utilities.color(state.board, {f, r}) do
            :white -> {List.to_atom([?a + Utilities.intify(f) + x]), r + y}
            :black -> {List.to_atom([?a + Utilities.intify(f) - x]), r - y}
            _ -> {f, r}
        end
    end

    defp starting_rank?(state, {f, r}) do
        case Utilities.color(state.board, {f, r}) do
            :white -> r == 2
            :black -> r == 7
            _ -> false
        end
    end

end
