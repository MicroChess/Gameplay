defmodule KubeChess.Rules.BishopMoves do

    alias KubeChess.Rules.Utilities

    def legal_moves(board, from) do
        diag1 = for x <- -7..7, do: Utilities.shift(board, from, {x, x})
        diag2 = for x <- -7..7, do: Utilities.shift(board, from, {x, -x})
        Enum.filter(diag1 ++ diag2, fn to -> valid_move?(board, from, to) end)
    end

    def valid_move?(state, from, to),
        do: Utilities.valid_diagonal_move?(state, from, to)
        and Map.get(state.squares, from) != nil
        and Map.get(state.squares, from) |> elem(0) == :bishop
end
