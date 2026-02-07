defmodule ClusterChess.Gameplay.Validator do

    def validate_move(board, from, to) do
        case Map.get(board, from) do
            nil -> {:error, :no_piece_at_from}
            {:king, _color}    -> valid_king_move(board, from, to)
            {:queen, _color}   -> valid_queen_move(board, from, to)
            {:rook, _color}    -> valid_rook_move(board, from, to)
            {:bishop, _color}  -> valid_bishop_move(board, from, to)
            {:pawn, _color}    -> valid_pawn_move(board, from, to)
            {:knight, _color}  -> valid_knight_move(board, from, to)
        end
    end

    def valid_king_move(board, {sf, sr}, {df, dr}) do
        sf_int = hd(Atom.to_charlist(sf)) - ?a
        df_int = hd(Atom.to_charlist(df)) - ?a
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
                {List.to_atom([?a + f]), r}
            end)
        else
            _ -> false
        end
    end

    def valid_bishop_move(board, {sf, sr}, {df, dr}) do
        with {_piece, color1} <- Map.get(board, {sf, sr}, {nil, nil}),
             {_piece, color2} <- Map.get(board, {df, dr}, {nil, nil}),
             true <- color1 != color2 and color1 != nil,
             sf_int = hd(Atom.to_charlist(sf)) - ?a,
             df_int = hd(Atom.to_charlist(df)) - ?a,
             true <- abs(sf_int - df_int) == abs(sr - dr),
             true <- {sf, sr} != {df, dr}
        do
            file_dir = if df_int > sf_int, do: 1, else: -1
            rank_dir = if dr > sr, do: 1, else: -1
            steps = abs(df_int - sf_int)
            valid_move_path(board, for i <- 0..steps do
                f = List.to_atom([?a + sf_int + i * file_dir])
                {f, sr + i * rank_dir}
            end)
        else
            _ -> false
        end
    end

    def valid_move_path(board, path) do
        {sf, sr} = hd(path)
        {df, dr} = List.last(path)
        Enum.all?(path, fn {f, r} ->
            {f, r} == {df, dr} or
            {f, r} == {sf, sr} or
            not Map.has_key?(board, {f, r})
        end) and length(path) > 1
    end

    def valid_pawn_move(board, {sf, sr}, {df, dr}) do
        with {_piece, color} <- Map.get(board, {sf, sr}),
             {_other, opponent_color} <- Map.get(board, {df, dr}, {nil, nil}),
             {from, to} <- {{sf, sr}, {df, dr}},
             sf_int <- hd(Atom.to_charlist(sf)) - ?a,
             df_int <- hd(Atom.to_charlist(df)) - ?a,
             true <- color == :white or sr > dr,
             true <- color == :black or sr < dr,
             true <- abs(sf_int - df_int) <= 1,
             true <- abs(sr - dr) <= 2,
             true <- {sf, sr} != {df, dr}
        do
            dest_clear = not Map.has_key?(board, to)
            dest_enemy = opponent_color not in [nil, color]
            vertical_diff = abs(sr - dr)
            horizontal_diff = abs(sf_int - df_int)
            case {vertical_diff, horizontal_diff, dest_clear} do
                {1, 0, true}  -> dest_clear
                {1, 1, false} -> dest_enemy
                {2, 0, true}  -> dest_clear and valid_rook_move(board, from, to)
                _ -> false
            end
        else
            _ -> false
        end
    end

    def valid_knight_move(board, {sf, sr}, {df, dr}) do
        with {_piece, color} <- Map.get(board, {sf, sr}),
             {_other, opponent} <- Map.get(board, {df, dr}, {nil, nil}),
             sf_int <- hd(Atom.to_charlist(sf)) - ?a,
             df_int <- hd(Atom.to_charlist(df)) - ?a
        do
            dest_ok = opponent != color
            vertical_diff = abs(sr - dr)
            horizontal_diff = abs(sf_int - df_int)
            case {vertical_diff, horizontal_diff} do
                {2, 1}  -> dest_ok
                {1, 2}  -> dest_ok
                _ -> false
            end
        else
            _ -> false
        end
    end

end
