defmodule KnightMoves do

    def apply_move!(board, from, to),
        do: board
        |>  BoardUpdates.update_en_passant_target(from, to)
        |>  BoardUpdates.update_fullmoves_counter(from, to)
        |>  BoardUpdates.update_halfmoves_counter(from, to)
        |>  BoardUpdates.update_current_turn()
        |>  BoardUpdates.update_squares_after_move(from, to)

    def legal_moves(board, from) do
        ms = for x <- -2..2, y <- -2..2, x != y, x != 0, y != 0, do:
            Squares.shift(board, from, {x, y})
        Enum.filter(ms, fn to -> valid_move?(board, from, to) end)
    end

    def valid_move?(board, from, to),
        do: both_distances(from, to) in [{1, 2}, {2, 1}]
        and BasicMoves.valid_move_ends?(board, from, to)
        and Map.get(board.squares, from) != nil
        and Map.get(board.squares, from) |> elem(0) == :knight

    defp both_distances(from, to), do: {
        horizontal_distance(from, to),
        vertical_distance(from, to)
    }

    defp horizontal_distance({sf, _}, {df, _}),
        do: abs(Squares.intify(sf) - Squares.intify(df))

    defp vertical_distance({_, sr}, {_, dr}),
        do: abs(sr - dr)
end
