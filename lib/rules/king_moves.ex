defmodule ClusterChess.Rules.KingMoves do

    alias ClusterChess.Rules.Utilities

    def valid_move?(state, from, to),
        do: (Utilities.valid_straight_move?(state, from, to)
        or  Utilities.valid_diagonal_move?(state, from, to))
        and horizontal_distance(from, to) in [0, 1]
        and vertical_distance(from, to) in [0, 1]

    defp horizontal_distance({sf, _}, {df, _}),
        do: abs(Utilities.intify(sf) - Utilities.intify(df))

    defp vertical_distance({_, sr}, {_, dr}),
        do: abs(sr - dr)
end
