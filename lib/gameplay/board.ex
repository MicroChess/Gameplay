defmodule Board do
    def color(board, pos) do
        case Map.get(board, pos) do
            nil -> nil
            {_piece, color} -> color
        end
    end

    def color(board, pos1, pos2),
        do: {color(board, pos1), color(board, pos2)}

    def intify(f),
        do: hd(Atom.to_charlist(f)) - ?a

    def intify(f1, f2),
        do: {intify(f1), intify(f2)}

    def direction(a, b),
        do: (if a < b, do: 1, else: -1)
end
