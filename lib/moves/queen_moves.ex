defmodule QueenMoves do

    def apply_move!(board, from, to),
        do: board
        |>  BoardUpdates.update_en_passant_target(from, to)
        |>  BoardUpdates.update_fullmoves_counter(from, to)
        |>  BoardUpdates.update_halfmoves_counter(from, to)
        |>  BoardUpdates.update_current_turn()
        |>  BoardUpdates.update_squares_after_move(from, to)

    def legal_moves(board, from) do
        hz = for x <- -7..7, do: Squares.shift(board, from, {x, 0})
        vt = for y <- -7..7, do: Squares.shift(board, from, {0, y})
        d1 = for z <- -7..7, do: Squares.shift(board, from, {z, z})
        d2 = for z <- -7..7, do: Squares.shift(board, from, {z, -z})
        moves = hz ++ vt ++ d1 ++ d2
        Enum.filter(moves, fn to -> valid_move?(board, from, to) end)
    end

    def valid_move?(state, from, to),
        do: valid_straight_move_or_diagonal_move?(state, from, to)
        and Map.get(state.squares, from) != nil
        and Map.get(state.squares, from) |> elem(0) == :queen

    def valid_straight_move_or_diagonal_move?(state, from, to),
        do: BasicMoves.valid_straight_move?(state, from, to)
        or  BasicMoves.valid_diagonal_move?(state, from, to)
end
