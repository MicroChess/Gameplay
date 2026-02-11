defmodule ClusterChess.Rules.Utilities do

    @files [:a, :b, :c, :d, :e, :f, :g, :h]
    @ranks [1, 2, 3, 4, 5, 6, 7, 8]

    alias ClusterChess.Rules.KingMoves
    alias ClusterChess.Rules.QueenMoves
    alias ClusterChess.Rules.RookMoves
    alias ClusterChess.Rules.BishopMoves
    alias ClusterChess.Rules.PawnMoves
    alias ClusterChess.Rules.KnightMoves

    def valid_move?(state, from, to) do
        case Map.get(state.board, from) do
            nil -> {:error, :no_piece_at_from}
            {:king, _color}    -> KingMoves.valid_move?(state, from, to)
            {:queen, _color}   -> QueenMoves.valid_move?(state, from, to)
            {:rook, _color}    -> RookMoves.valid_move?(state, from, to)
            {:bishop, _color}  -> BishopMoves.valid_move?(state, from, to)
            {:pawn, _color}    -> PawnMoves.valid_move?(state, from, to)
            {:knight, _color}  -> KnightMoves.valid_move?(state, from, to)
        end
    end

    def valid_move_ends?(state, {sf, sr}, {df, dr}) do
        {from, to} = {{sf, sr}, {df, dr}}
        {color1, color2} = color(state.board, from, to)
        color1 != color2 and color1 != nil and
        sf in @files and df in @files and
        sr in @ranks and dr in @ranks
    end

    def valid_move_path?(state, path) do
        from = {sf, sr} = hd(path)
        to = {df, dr} = List.last(path)
        Enum.all?(path, fn {f, r} ->
            {f, r} in [{df, dr}, {sf, sr}]
            or not Map.has_key?(state.board, {f, r})
        end)
        and length(path) > 1
        and valid_move_ends?(state, from, to)
    end

    def valid_straight_move?(state, {sf, sr}, {df, dr}) do
        {sf_int, df_int} = intify(sf, df)
        path = for f <- (sf_int .. df_int), r <- (sr .. dr) do
            {List.to_atom([?a + f]), r}
        end
        straight? = sf == df or sr == dr
        valid_move_path?(state, path) and straight?
    end

    def valid_diagonal_move?(state, {sf, sr}, {df, dr}) do
        {sf_int, df_int} = intify(sf, df)
        path = for i <- 0..abs(df_int - sf_int) do
            f = List.to_atom([?a + sf_int + i * direction(sf_int, df_int)])
            {f, sr + i * direction(sr, dr)}
        end
        diagonal? = abs(sf_int - df_int) == abs(sr - dr)
        valid_move_path?(state, path) and diagonal?
    end

    def color(board, pos) do
        case Map.get(board, pos) do
            nil -> nil
            {_piece, color} -> color
        end
    end

    def empty?(board, pos), do: color(board, pos) == nil
    def color(b, p1, p2), do: {color(b, p1), color(b, p2)}
    def intify(f), do: hd(Atom.to_charlist(f)) - ?a
    def intify(f1, f2), do: {intify(f1), intify(f2)}
    def direction(a, b), do: (if a < b, do: 1, else: -1)
end
