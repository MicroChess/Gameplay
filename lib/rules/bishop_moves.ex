defmodule ClusterChess.Rules.BishopMoves do

    alias ClusterChess.Rules.Utilities

    def valid_move?(state, from, to),
        do: Utilities.valid_diagonal_move?(state, from, to)
        and Map.get(state.squares, from) != nil
        and Map.get(state.squares, from) |> elem(0) == :bishop
end
