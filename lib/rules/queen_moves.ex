defmodule ClusterChess.Rules.QueenMoves do

    alias ClusterChess.Rules.Utilities

    def valid_move?(state, from, to),
        do: valid_straight_move_or_diagonal_move?(state, from, to)
        and Map.get(state.squares, from) != nil
        and Map.get(state.squares, from) |> elem(0) == :queen

    def valid_straight_move_or_diagonal_move?(state, from, to),
        do: Utilities.valid_straight_move?(state, from, to)
        or  Utilities.valid_diagonal_move?(state, from, to)
end
