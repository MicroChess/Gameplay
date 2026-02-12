defmodule ClusterChess.Rules.KingMoves do

    alias ClusterChess.Rules.Utilities

    def valid_move?(state, from, to),
        do: valid_push_or_capture?(state, from, to)
        or  valid_castling?(state, from, to)

    def valid_push_or_capture?(state, from, to),
        do: (Utilities.valid_straight_move?(state, from, to)
        or  Utilities.valid_diagonal_move?(state, from, to))
        and horizontal_distance(from, to) in [0, 1]
        and vertical_distance(from, to) in [0, 1]

    defp horizontal_distance({sf, _}, {df, _}),
        do: abs(Utilities.intify(sf) - Utilities.intify(df))

    defp vertical_distance({_, sr}, {_, dr}),
        do: abs(sr - dr)

    def valid_castling?(state, from, to),
        do: valid_castling_path?(state, from, to)
        and valid_castling_ends?(state, from, to)

    def valid_castling_path?(state, from, to) do
        {piece, color} = Map.get(state.board, from, {nil, nil})
        case {piece, color, to} do
            {:king, :white, {:c, 1}} -> safe_castling_path?(state, from, {:b, 1}, to)
            {:king, :white, {:g, 1}} -> safe_castling_path?(state, from, {:f, 1}, to)
            {:king, :black, {:c, 8}} -> safe_castling_path?(state, from, {:b, 8}, to)
            {:king, :black, {:g, 8}} -> safe_castling_path?(state, from, {:f, 8}, to)
            _ -> false
        end
    end

    def safe_castling_path?(state, {sf, sr}, extension, {df, dr}) do
        {sf_int, df_int} = Utilities.intify(sf, df)
        path = for f <- (sf_int .. df_int), r <- (sr .. dr), do: {List.to_atom([?a + f]), r}
        king_color = Utilities.color(state.board, {sf, sr})

        enemies = for {enemy, {_, color}} <- state.board,
            color not in [nil, king_color], do: enemy

        Utilities.valid_straight_move?(state, {sf, sr}, extension)
        and Enum.all?(for king <- path, enemy <- enemies,
            do: not Utilities.valid_move?(state, enemy, king)
        )
    end

    def valid_castling_ends?(state, from, to) do
        {piece, color} = Map.get(state.board, from, {nil, nil})
        case {piece, color, to} do
            {:king, :white, {:c, 1}} -> state.castling_rights.white_queenside
            {:king, :white, {:g, 1}} -> state.castling_rights.white_kingside
            {:king, :black, {:c, 8}} -> state.castling_rights.black_queenside
            {:king, :black, {:g, 8}} -> state.castling_rights.black_kingside
            _ -> false
        end
    end
end
