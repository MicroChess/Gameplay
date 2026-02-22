defmodule Game.Utilities do

    @files [:a, :b, :c, :d, :e, :f, :g, :h]
    @ranks [1, 2, 3, 4, 5, 6, 7, 8]

    def valid_move_ends?(state, {sf, sr}, {df, dr}) do
        {from, to} = {{sf, sr}, {df, dr}}
        {color1, color2} = both_colors(state.squares, from, to)
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
        {sf_int, df_int} = intify(sf, df)
        for f <- range(sf_int, df_int), r <- range(sr, dr),
            do: {List.to_atom([?a + f]), r}
    end

    def valid_straight_move?(state, {sf, sr}, {df, dr}) do
        {sf_int, df_int} = intify(sf, df)
        path = for f <- range(sf_int, df_int), r <- range(sr, dr) do
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

    def shift(state, {f, r}, {x, y}) do
        case color(state.squares, {f, r}) do
            :white -> {List.to_atom([?a + intify(f) + x]), r + y}
            :black -> {List.to_atom([?a + intify(f) + x]), r - y}
            _ -> {f, r}
        end
    end

    def opponent(:white), do: :black
    def opponent(:black), do: :white
    def both_colors(b, p1, p2), do: {color(b, p1), color(b, p2)}
    def horizontal_distance({sf, _}, {df, _}), do: abs(intify(sf) - intify(df))
    def vertical_distance({_, sr}, {_, dr}), do: abs(sr - dr)
    def empty?(board, pos), do: color(board, pos) == nil
    def intify(f), do: hd(Atom.to_charlist(f)) - ?a
    def intify(f1, f2), do: {intify(f1), intify(f2)}
    def direction(a, b), do: (if a < b, do: 1, else: -1)
    def range(a, b), do: Range.new(a, b, direction(a, b))
end
