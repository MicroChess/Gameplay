defmodule ClusterChess.Gameplay.Validator do

    def validate_move(board, from, to) do
        case Map.get(board, from) do
            nil -> {:error, :no_piece_at_from}
            {:king, _color}    -> valid_king_move(board, from, to)
            {:queen, _color}   -> valid_queen_move(board, from, to)
            {:rook, _color}    -> valid_rook_move(board, from, to)
            {:bishop, _color}  -> valid_bishop_move(board, from, to)
            #{:pawn, _color}   -> valid_pawn_move(board, from, to)
            #{:knight, _color} -> valid_pawn_move(board, from, to)
        end
    end

    def valid_king_move(board, {sf, sr}, {df, dr}) do
        sf_int = hd(Atom.to_charlist(sf)) - ?a + 1
        df_int = hd(Atom.to_charlist(df)) - ?a + 1
        {fdiff, rdiff} = {abs(sf_int - df_int), abs(sr - dr)}
        valid_queen_move(board, {sf, sr}, {df, dr}) and fdiff <= 1 and rdiff <= 1
    end

    def valid_queen_move(board, from, to),
        do: valid_rook_move(board, from, to)
        or valid_bishop_move(board, from, to)

    def valid_rook_move(board, {sf, sr}, {df, dr}) do
        with {_piece, color1} <- Map.get(board, {sf, sr}, {nil, nil}),
             {_piece, color2} <- Map.get(board, {df, dr}, {nil, nil}),
             true <- color1 != color2 and color1 != nil,
             true <- sf == df or sr == dr,
             true <- {sf, sr} != {df, dr}
        do
            sf_int = hd(Atom.to_charlist(sf)) - ?a
            df_int = hd(Atom.to_charlist(df)) - ?a
            valid_move_path(board, for f <- (sf_int .. df_int), r <- (sr .. dr) do
                f_atom = List.to_atom([?a + f])
                Map.get(board, {f_atom, r})
            end)
        else
            _ -> false
        end
    end

    def valid_bishop_move(board, {sf, sr}, {df, dr}) do
        with {_piece, color1} <- Map.get(board, {sf, sr}, {nil, nil}),
             {_piece, color2} <- Map.get(board, {df, dr}, {nil, nil}),
             true <- color1 != color2 and color1 != nil,
             sf_int = hd(Atom.to_charlist(sf)) - ?a ,
             df_int = hd(Atom.to_charlist(df)) - ?a,
             true <- (sf_int - df_int) == (sr - dr),
             true <- {sf, sr} != {df, dr}
        do
            valid_move_path(board, for idx <- (sr .. dr) do
                f_atom = List.to_atom([?a + idx])
                Map.get(board, {f_atom, idx})
            end)
        end
    end

    def valid_move_path(board, path) do
        {sf, sr} = hd(path)
        {df, dr} = List.last(path)
        Enum.all?(path, fn {f, r} ->
            {f, r} == {df, dr} or
            {f, r} == {sf, sr} or
            Map.has_key?(board, {f, r})
        end)
    end
end
