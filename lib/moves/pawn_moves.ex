defmodule PawnMoves do

    def promote!(board, from, to, promotion \\ :pawn),
        do: apply_move!(board, from, to)
        |>  Map.put(to, {promotion, Squares.color(board, to)})

    def apply_move!(board, from, to),
        do: capture_en_passant_target(board, to)
        |>  BoardUpdates.update_en_passant_target(from, to)
        |>  BoardUpdates.update_fullmoves_counter(from, to)
        |>  BoardUpdates.update_halfmoves_counter(from, to)
        |>  BoardUpdates.update_current_turn()
        |>  BoardUpdates.update_squares_after_move(from, to)

    defp capture_en_passant_target(board, to) do
        target = Squares.shift(board, to, {0, 1})
        case board.en_passant_target == to do
            true -> %{ board | squares: Map.put(board.squares, target, nil) }
            false -> board
        end
    end

    def legal_moves(board, from) do
        ms = for x <- -1..1, y <- 1..2, do:
            Squares.shift(board, from, {x, y})
        Enum.filter(ms, fn to -> valid_move?(board, from, to) end)
    end

    def valid_final_push?(board, from, to),
        do: valid_single_push?(board, from, to)
        and (to |> elem(1)) in [1, 8]

    def valid_move?(state, from, to),
        do: valid_push_or_capture_or_en_passant?(state, from, to)
        and Map.get(state.squares, from) != nil
        and Map.get(state.squares, from) |> elem(0) == :pawn

    def valid_push_or_capture_or_en_passant?(state, from, to),
        do: valid_single_push?(state, from, to)
        or  valid_double_push?(state, from, to)
        or  valid_capture?(state, from, to)
        or  valid_en_passant?(state, from, to)

    def valid_single_push?(state, from, to),
        do: Squares.shift(state, from, {0, 1}) == to
        and Squares.empty?(state.squares, to)

    def valid_double_push?(state, from, to),
        do: Squares.shift(state, from, {0, 2}) == to
        and starting_rank?(Squares.color(state.squares, from), from)
        and Squares.empty?(state.squares, Squares.shift(state, from, {0, 1}))
        and Squares.empty?(state.squares, Squares.shift(state, from, {0, 2}))

    def valid_capture?(state, from, to),
        do: to in bilateral_increments(state, from, {1, 1})
        and Squares.color(state.squares, to) != Squares.color(state.squares, from)
        and Squares.color(state.squares, to) != nil

    def valid_en_passant?(state, from, to),
        do: to in bilateral_increments(state, from, {1, 1})
        and state.en_passant_target in bilateral_increments(state, from, {1, 0})
        and Squares.color(state.squares, to) == nil
        and state.en_passant_target != nil
        and Map.get(state.squares, from) != nil
        and Map.get(state.squares, from) |> elem(0) == :pawn

    defp starting_rank?(:white, {_file, r}), do: r == 2
    defp starting_rank?(:black, {_file, r}), do: r == 7

    defp bilateral_increments(state, {f, r}, {x, y}), do: [
        Squares.shift(state, {f, r}, {x, y}),
        Squares.shift(state, {f, r}, {-x, y})
    ]
end
