defmodule Squares do

    def default(), do: %{
        {:a, 1} => {:rook,   :white}, {:a, 2} => {:pawn, :white},
        {:b, 1} => {:knight, :white}, {:c, 2} => {:pawn, :white},
        {:c, 1} => {:bishop, :white}, {:e, 2} => {:pawn, :white},
        {:d, 1} => {:queen,  :white}, {:g, 2} => {:pawn, :white},
        {:e, 1} => {:king,   :white}, {:b, 2} => {:pawn, :white},
        {:f, 1} => {:bishop, :white}, {:d, 2} => {:pawn, :white},
        {:g, 1} => {:knight, :white}, {:f, 2} => {:pawn, :white},
        {:h, 1} => {:rook,   :white}, {:h, 2} => {:pawn, :white},
        {:a, 8} => {:rook,   :black}, {:a, 7} => {:pawn, :black},
        {:b, 8} => {:knight, :black}, {:c, 7} => {:pawn, :black},
        {:c, 8} => {:bishop, :black}, {:e, 7} => {:pawn, :black},
        {:d, 8} => {:queen,  :black}, {:g, 7} => {:pawn, :black},
        {:e, 8} => {:king,   :black}, {:b, 7} => {:pawn, :black},
        {:f, 8} => {:bishop, :black}, {:d, 7} => {:pawn, :black},
        {:g, 8} => {:knight, :black}, {:f, 7} => {:pawn, :black},
        {:h, 8} => {:rook,   :black}, {:h, 7} => {:pawn, :black},
    }

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

    def opponent_color(:white), do: :black
    def opponent_color(:black), do: :white
    def both_colors(b, p1, p2), do: {color(b, p1), color(b, p2)}

    def horizontal_distance({sf, _}, {df, _}), do: abs(intify(sf) - intify(df))
    def vertical_distance({_, sr}, {_, dr}), do: abs(sr - dr)
    def empty?(board, pos), do: color(board, pos) == nil

    def intify(f), do: hd(Atom.to_charlist(f)) - ?a
    def intify(f1, f2), do: {intify(f1), intify(f2)}
    def direction(a, b), do: (if a < b, do: 1, else: -1)
    def range(a, b), do: Range.new(a, b, direction(a, b))
end
