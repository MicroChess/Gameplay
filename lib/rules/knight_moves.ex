defmodule KubeChess.Rules.KnightMoves do

    alias KubeChess.Rules.Utilities

    def legal_moves(board, from) do
        ms = for x <- -2..2, y <- -2..2, x != y, x != 0, y != 0, do:
            Utilities.shift(board, from, {x, y})
        Enum.filter(ms, fn to -> valid_move?(board, from, to) end)
    end

    def valid_move?(board, from, to),
        do: both_distances(from, to) in [{1, 2}, {2, 1}]
        and Utilities.valid_move_ends?(board, from, to)
        and Map.get(board.squares, from) != nil
        and Map.get(board.squares, from) |> elem(0) == :knight

    defp both_distances(from, to), do: {
        horizontal_distance(from, to),
        vertical_distance(from, to)
    }

    defp horizontal_distance({sf, _}, {df, _}),
        do: abs(Utilities.intify(sf) - Utilities.intify(df))

    defp vertical_distance({_, sr}, {_, dr}),
        do: abs(sr - dr)
end
