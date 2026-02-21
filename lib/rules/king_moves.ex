defmodule KubeChess.Rules.KingMoves do

    alias KubeChess.Rules.Board
    alias KubeChess.Rules.Utilities

    def legal_moves(board, from) do
        castlings = [{:c, 1}, {:g, 1}, {:c, 8}, {:g, 8}]
        ms = for x <- -1..1, y <- -1..1, do: Utilities.shift(board, from, {x, y})
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
        and Utilities.horizontal_distance(from, to) in [0, 1]
        and Utilities.vertical_distance(from, to) in [0, 1]

    def valid_straight_move_or_diagonal_move?(state, from, to),
        do: Utilities.valid_straight_move?(state, from, to)
        or  Utilities.valid_diagonal_move?(state, from, to)

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
        king_color = Utilities.color(state.squares, from)
        path = Utilities.path(from, to)
        enemies = Board.enemies(state, king_color)
        Utilities.valid_straight_move?(state, from, extension)
        and Enum.all?(for king <- path, enemy <- enemies,
            do: not Board.valid_move?(state, enemy, king)
        )
    end

    def valid_castling_ends?(state, from, to) do
        {piece, color} = Map.get(state.squares, from, {nil, nil})
        case {piece, color, to} do
            {:king, :white, {:c, 1}} -> state.castling_rights.white_queenside
            {:king, :white, {:g, 1}} -> state.castling_rights.white_kingside
            {:king, :black, {:c, 8}} -> state.castling_rights.black_queenside
            {:king, :black, {:g, 8}} -> state.castling_rights.black_kingside
            _ -> false
        end
    end
end
