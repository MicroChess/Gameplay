defmodule ClusterChess.Rules.BishopMoves do

    alias ClusterChess.Rules.Utilities

    def valid_move?(state, from, to),
        do: Utilities.valid_diagonal_move?(state, from, to)
end
