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

    def all_legal_moves(state, target_color) do
        for {square, {_, piece_color}} <- state.squares,
            target_color == piece_color,
            to <- Board.legal_moves(state, square),
        do: {square, to}
    end

    def king_location(board, color) do
        case color do
            :white -> board.white_king_location
            :black -> board.black_king_location
        end
    end

    def enemies(state, friendly_color) do
        for {enemy, {_, color}} <- state.squares,
            color not in [nil, friendly_color], do: enemy
    end

    def allies(state, friendly_color) do
        for {ally, {_, color}} <- state.squares,
            color == friendly_color, do: ally
    end

    def king_in_check?(board, color) do
        king_loc = king_location(board, color)
        enemies = enemies(board, color)
        Enum.any?(enemies, fn enemy ->
            Board.valid_move?(board, enemy, king_loc)
        end)
    end

    def king_status(board, color) do
        legal_moves = all_legal_moves(board, color)
        in_check? = king_in_check?(board, color)
        all_checks = all_moves_bring_to_check?(board, color, legal_moves)
        case {all_checks, in_check?} do
            {true, true}  -> :checkmate
            {true, false} -> :stalemate
            _some_other -> :safe
        end
    end

    defp all_moves_bring_to_check?(board, color, all_legal_moves) do
        Enum.all?(all_legal_moves, fn {from, to} ->
            new_board = Board.apply_move!(board, from, to)
            valid? = (new_board != :invalid_move)
            valid? and king_in_check?(new_board, color)
        end)
    end
end
