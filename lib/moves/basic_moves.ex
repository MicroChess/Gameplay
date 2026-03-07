defmodule BasicMoves do

    @files [:a, :b, :c, :d, :e, :f, :g, :h]
    @ranks [1, 2, 3, 4, 5, 6, 7, 8]

    def valid_move_ends?(state, {sf, sr}, {df, dr}) do
        {from, to} = {{sf, sr}, {df, dr}}
        {color1, color2} = Squares.both_colors(state.squares, from, to)
        color1 != color2 and color1 != nil and
        sf in @files and df in @files and
        sr in @ranks and dr in @ranks
    end

    defp valid_move_path?(state, path) do
        from = {sf, sr} = hd(path)
        to = {df, dr} = List.last(path)
        length(path) > 1 and
        valid_move_ends?(state, from, to) and
        Enum.all?(path, fn {f, r} ->
            {f, r} in [{df, dr}, {sf, sr}]
            or not Map.has_key?(state.squares, {f, r})
        end)
    end

    def path({sf, sr}, {df, dr}) do
        {sf_int, df_int} = Squares.intify(sf, df)
        for f <- Squares.range(sf_int, df_int), r <- Squares.range(sr, dr),
            do: {List.to_atom([?a + f]), r}
    end

    def valid_straight_move?(state, {sf, sr}, {df, dr}) do
        {sf_int, df_int} = Squares.intify(sf, df)
        path = for f <- Squares.range(sf_int, df_int), r <- Squares.range(sr, dr) do
            {List.to_atom([?a + f]), r}
        end
        straight? = sf == df or sr == dr
        valid_move_path?(state, path) and straight?
    end

    def valid_diagonal_move?(state, {sf, sr}, {df, dr}) do
        {sf_int, df_int} = Squares.intify(sf, df)
        path = for i <- 0..abs(df_int - sf_int) do
            f = List.to_atom([?a + sf_int + i * Squares.direction(sf_int, df_int)])
            {f, sr + i * Squares.direction(sr, dr)}
        end
        diagonal? = abs(sf_int - df_int) == abs(sr - dr)
        valid_move_path?(state, path) and diagonal?
    end

end
