defmodule ClusterChess.Rules.RookMoves do

    alias ClusterChess.Rules.Utilities

    def valid_move?(state, from, to),
        do: Utilities.valid_straight_move?(state, from, to)
        and Map.get(state.squares, from) != nil
        and Map.get(state.squares, from) |> elem(0) == :rook
end
