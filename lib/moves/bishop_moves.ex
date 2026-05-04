defmodule BishopMoves do

    def apply_move!(board, from, to),
        do: BoardUpdates.update_en_passant_target(board, from, to)
        |>  BoardUpdates.update_fullmoves_counter(from, to)
        |>  BoardUpdates.update_halfmoves_counter(from, to)
        |>  BoardUpdates.update_current_turn()
        |>  BoardUpdates.update_squares_after_move(from, to)

    def legal_moves(board, from) do
        diag1 = for x <- -7..7, do: Squares.shift(board, from, {x, x})
        diag2 = for x <- -7..7, do: Squares.shift(board, from, {x, -x})
        Enum.filter(diag1 ++ diag2, fn to -> valid_move?(board, from, to) end)
    end

    def valid_move?(state, from, to),
        do: BasicMoves.valid_diagonal_move?(state, from, to)
        and Map.get(state.squares, from) != nil
        and Map.get(state.squares, from) |> elem(0) == :bishop
end
