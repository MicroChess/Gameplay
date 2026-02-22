defmodule Game.MakeUpdates do

    alias Game.Utilities

    def update_all(board, from, to),
        do: board
        |>  update_halfmoves_counter(from, to)
        |>  update_fullmoves_counter(from, to)
        |>  update_en_passant_target(from, to)
        |>  update_castling_rights(from, to)
        |>  update_king_location(from, to)
        |>  Map.put(:turn, Utilities.opponent(board.turn))

    def update_halfmoves_counter(board, from, to) do
        {piece, _color} = Map.get(board.squares, from, {nil, nil})
        pawn_move? = piece == :pawn
        capture? = Map.get(board.squares, to) != nil
        old = board.counters.halfmoves
        new = if pawn_move? or capture?, do: 0, else: old + 1
        %{board | counters: %{ board.counters | halfmoves: new }}
    end

    def update_fullmoves_counter(board, _from, _to) do
        diff = if board.turn == :black, do: 1, else: 0
        new = board.counters.fullmoves + diff
        %{board | counters: %{ board.counters | fullmoves: new }}
    end

    def update_en_passant_target(board, from, to) do
        square = Map.get(board.squares, from, {nil, nil})
        piece = elem(square, 0)
        distance = Utilities.vertical_distance(from, to)
        target = Utilities.shift(board, from, {0, 1})
        case {piece, distance} do
            {:pawn, 2}  -> %{board | en_passant_target: target}
            {:pawn, -2} -> %{board | en_passant_target: target}
            _some_other -> %{board | en_passant_target: nil}
        end
    end

    def update_castling_rights(board, from, _to) do
        {piece, color} = Map.get(board.squares, from, {nil, nil})
        rights = board.castling_rights
        new_rights = case {piece, color, from} do
            {:king, :white, {:e, 1}} -> %{rights | white_lx: false, white_rx: false}
            {:rook, :white, {:a, 1}} -> %{rights | white_rx: false}
            {:rook, :white, {:h, 1}} -> %{rights | white_lx: false}
            {:king, :black, {:e, 8}} -> %{rights | black_lx: false, black_rx: false}
            {:rook, :black, {:a, 8}} -> %{rights | black_rx: false}
            {:rook, :black, {:h, 8}} -> %{rights | black_lx: false}
            _ -> rights
        end
        %{board | castling_rights: new_rights}
    end

    def update_king_location(board, from, to) do
        {piece, color} = Map.get(board.squares, from, {nil, nil})
        case {piece, color} do
            {:king, :white} -> %{board | white_king_location: to}
            {:king, :black} -> %{board | black_king_location: to}
            _ -> board
        end
    end
end
