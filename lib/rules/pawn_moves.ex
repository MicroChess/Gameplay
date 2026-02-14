defmodule ClusterChess.Rules.PawnMoves do

    alias ClusterChess.Rules.Utilities

    def legal_moves(board, from) do
        ms = for x <- -1..1, y <- 1..2, do:
            Utilities.shift(board, from, {x, y})
        Enum.filter(ms, fn to -> valid_move?(board, from, to) end)
    end

    def valid_move?(state, from, to),
        do: valid_push_or_capture_or_en_passant?(state, from, to)
        and Map.get(state.squares, from) != nil
        and Map.get(state.squares, from) |> elem(0) == :pawn

    def valid_push_or_capture_or_en_passant?(state, from, to),
        do: valid_single_push?(state, from, to)
        or  valid_double_push?(state, from, to)
        or  valid_capture?(state, from, to)
        or  valid_en_passant?(state, from, to)

    def valid_single_push?(state, from, to),
        do: Utilities.shift(state, from, {0, 1}) == to
        and Utilities.empty?(state.squares, to)

    def valid_double_push?(state, from, to),
        do: Utilities.shift(state, from, {0, 2}) == to
        and starting_rank?(Utilities.color(state.squares, from), from)
        and Utilities.empty?(state.squares, Utilities.shift(state, from, {0, 1}))
        and Utilities.empty?(state.squares, Utilities.shift(state, from, {0, 2}))

    def valid_capture?(state, from, to),
        do: to in bilateral_increments(state, from, {1, 1})
        and Utilities.color(state.squares, to) != Utilities.color(state.squares, from)
        and Utilities.color(state.squares, to) != nil

    def valid_en_passant?(state, from, to),
        do: to in bilateral_increments(state, from, {1, 1})
        and state.en_passant_target in bilateral_increments(state, from, {1, 0})
        and Utilities.color(state.squares, to) == nil
        and state.en_passant_target != nil
        and Map.get(state.squares, from) != nil
        and Map.get(state.squares, from) |> elem(0) == :pawn

    defp starting_rank?(:white, {_file, r}), do: r == 2
    defp starting_rank?(:black, {_file, r}), do: r == 7

    defp bilateral_increments(state, {f, r}, {x, y}), do: [
        Utilities.shift(state, {f, r}, {x, y}),
        Utilities.shift(state, {f, r}, {-x, y})
    ]
end
