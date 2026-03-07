defmodule RookMoves do

    def apply_move!(board, from, to),
        do: MetaData.update_castling_rights(board, from, to)
        |>  MetaData.update_en_passant_target(from, to)
        |>  MetaData.update_fullmoves_counter(from, to)
        |>  MetaData.update_halfmoves_counter(from, to)
        |>  MetaData.update_current_turn()
        |>  MetaData.update_squares_after_move(from, to)

    def legal_moves(board, from) do
        hz = for x <- -7..7, do: Squares.shift(board, from, {x, 0})
        vt = for y <- -7..7, do: Squares.shift(board, from, {0, y})
        Enum.filter(hz ++ vt, fn to -> valid_move?(board, from, to) end)
    end

    def valid_move?(state, from, to),
        do: BasicMoves.valid_straight_move?(state, from, to)
        and Map.get(state.squares, from) != nil
        and Map.get(state.squares, from) |> elem(0) == :rook
end
