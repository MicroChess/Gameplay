defmodule Utilities do

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
