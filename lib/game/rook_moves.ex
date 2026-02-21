defmodule KubeChess.Game.RookMoves do

    alias KubeChess.Game.Utilities

    def legal_moves(board, from) do
        hz = for x <- -7..7, do: Utilities.shift(board, from, {x, 0})
        vt = for y <- -7..7, do: Utilities.shift(board, from, {0, y})
        Enum.filter(hz ++ vt, fn to -> valid_move?(board, from, to) end)
    end

    def valid_move?(state, from, to),
        do: Utilities.valid_straight_move?(state, from, to)
        and Map.get(state.squares, from) != nil
        and Map.get(state.squares, from) |> elem(0) == :rook
end
