defmodule KingMoves do

    def apply_move!(board, from, to),
        do: BoardUpdates.update_king_location(board, from, to)
        |>  update_rooks_positions_before_castling(from, to)
        |>  BoardUpdates.update_castling_rights(from, to)
        |>  BoardUpdates.update_en_passant_target(from, to)
        |>  BoardUpdates.update_fullmoves_counter(from, to)
        |>  BoardUpdates.update_halfmoves_counter(from, to)
        |>  BoardUpdates.update_current_turn()
        |>  BoardUpdates.update_squares_after_move(from, to)

    defp update_rooks_positions_before_castling(board, from, to) do
        {_piece, color} = Map.get(board.squares, from, {nil, nil})
        case {color, to} do
            {:white, {:c, 1}} -> BoardUpdates.update_squares_after_move(board, {:a, 1}, {:d, 1})
            {:white, {:g, 1}} -> BoardUpdates.update_squares_after_move(board, {:h, 1}, {:f, 1})
            {:black, {:c, 8}} -> BoardUpdates.update_squares_after_move(board, {:a, 8}, {:d, 8})
            {:black, {:g, 8}} -> BoardUpdates.update_squares_after_move(board, {:h, 8}, {:f, 8})
            _ -> board
        end
    end

    def legal_moves(board, from) do
        castlings = [{:c, 1}, {:g, 1}, {:c, 8}, {:g, 8}]
        ms = for x <- -1..1, y <- -1..1, do: Squares.shift(board, from, {x, y})
        Enum.filter(ms ++ castlings, fn to -> valid_move?(board, from, to) end)
    end

    def valid_move?(state, from, to),
        do: valid_push_or_capture_or_castling?(state, from, to)
        and Map.get(state.squares, from) != nil
        and Map.get(state.squares, from) |> elem(0) == :king

    def valid_push_or_capture_or_castling?(state, from, to),
        do: valid_push_or_capture?(state, from, to)
        or  valid_castling?(state, from, to)

    def valid_push_or_capture?(state, from, to),
        do: valid_straight_move_or_diagonal_move?(state, from, to)
        and Squares.horizontal_distance(from, to) in [0, 1]
        and Squares.vertical_distance(from, to) in [0, 1]

    def valid_straight_move_or_diagonal_move?(state, from, to),
        do: BasicMoves.valid_straight_move?(state, from, to)
        or  BasicMoves.valid_diagonal_move?(state, from, to)

    def valid_castling?(state, from, to),
        do: valid_castling_path?(state, from, to)
        and valid_castling_ends?(state, from, to)
        and Map.get(state.squares, from) != nil
        and Map.get(state.squares, from) |> elem(0) == :king

    def valid_castling_path?(state, from, to) do
        {piece, color} = Map.get(state.squares, from, {nil, nil})
        case {piece, color, to} do
            {:king, :white, {:c, 1}} -> safe_castling_path?(state, from, {:b, 1}, to)
            {:king, :white, {:g, 1}} -> safe_castling_path?(state, from, {:f, 1}, to)
            {:king, :black, {:c, 8}} -> safe_castling_path?(state, from, {:b, 8}, to)
            {:king, :black, {:g, 8}} -> safe_castling_path?(state, from, {:f, 8}, to)
            _ -> false
        end
    end

    def safe_castling_path?(state, from, extension, to) do
        king_color = Squares.color(state.squares, from)
        path = BasicMoves.path(from, to)
        enemies = Squares.enemies(state, king_color)
        BasicMoves.valid_straight_move?(state, from, extension)
        and Enum.all?(for king <- path, enemy <- enemies,
            do: not Board.valid_move?(state, enemy, king)
        )
    end

    def valid_castling_ends?(state, from, to) do
        {piece, color} = Map.get(state.squares, from, {nil, nil})
        case {piece, color, to} do
            {:king, :white, {:c, 1}} -> state.castling_rights.white_rx
            {:king, :white, {:g, 1}} -> state.castling_rights.white_lx
            {:king, :black, {:c, 8}} -> state.castling_rights.black_rx
            {:king, :black, {:g, 8}} -> state.castling_rights.black_lx
            _ -> false
        end
    end
end
