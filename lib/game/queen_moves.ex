defmodule Game.QueenMoves do

    alias Game.Utilities

    def legal_moves(board, from) do
        hz = for x <- -7..7, do: Utilities.shift(board, from, {x, 0})
        vt = for y <- -7..7, do: Utilities.shift(board, from, {0, y})
        d1 = for z <- -7..7, do: Utilities.shift(board, from, {z, z})
        d2 = for z <- -7..7, do: Utilities.shift(board, from, {z, -z})
        moves = hz ++ vt ++ d1 ++ d2
        Enum.filter(moves, fn to -> valid_move?(board, from, to) end)
    end

    def valid_move?(state, from, to),
        do: valid_straight_move_or_diagonal_move?(state, from, to)
        and Map.get(state.squares, from) != nil
        and Map.get(state.squares, from) |> elem(0) == :queen

    def valid_straight_move_or_diagonal_move?(state, from, to),
        do: Utilities.valid_straight_move?(state, from, to)
        or  Utilities.valid_diagonal_move?(state, from, to)
end
