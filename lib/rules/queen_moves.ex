defmodule ClusterChess.Rules.QueenMoves do

    alias ClusterChess.Rules.Utilities

    def valid_move?(state, from, to),
        do: Utilities.valid_straight_move?(state, from, to)
        or  Utilities.valid_diagonal_move?(state, from, to)
end
