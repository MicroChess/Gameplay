defmodule ClusterChess.Gameplay.Knights.Test do
    use ExUnit.Case

    alias ClusterChess.Rules.KnightMoves
    @files [:a, :b, :c, :d, :e, :f, :g, :h]
    @ranks [1, 2, 3, 4, 5, 6, 7, 8]

    test "knight move ok [L-shape, b1 -> c3, no capture]" do
        board = %{ {:b, 1} => {:knight, :white} }
        state = %{board: board, castling_rights: %{}}
        assert KnightMoves.valid_move?(state, {:b, 1}, {:c, 3})
    end

    test "knight move ok [L-shape, c3 -> b1, no capture]" do
        board = %{ {:c, 3} => {:knight, :white} }
        state = %{board: board, castling_rights: %{}}
        assert KnightMoves.valid_move?(state, {:c, 3}, {:b, 1})
    end

    test "knight move ok [L-shape, c3 -> b1, capture]" do
        board = %{ {:c, 3} => {:knight, :white}, {:b, 1} => {:pawn, :black} }
        state = %{board: board, castling_rights: %{}}
        assert KnightMoves.valid_move?(state, {:c, 3}, {:b, 1})
    end

    test "knight move ok [L-shape, c3 -> b1, with suicide]" do
        board = %{ {:c, 3} => {:knight, :white}, {:b, 1} => {:pawn, :white} }
        state = %{board: board, castling_rights: %{}}
        assert not KnightMoves.valid_move?(state, {:c, 3}, {:b, 1})
    end

    test "knight move ok [L-shape, c3 -> b1, with jump over opponents]" do
        board = for f <- @files, r <- @ranks, into: %{} do
            {{f, r}, {:pawn, :black}}
        end
        board = Map.put(board, {:c, 3}, {:knight, :white})
        state = %{board: board, castling_rights: %{}}
        assert KnightMoves.valid_move?(state, {:c, 3}, {:b, 1})
    end

    test "knight move ok [L-shape, c3 -> b1, with over firends]" do
        board = for f <- @files, r <- @ranks, into: %{} do
            {{f, r}, {:pawn, :white}}
        end
        board = Map.put(board, {:c, 3}, {:knight, :white})
        board = Map.put(board, {:b, 1}, {:rook, :black})
        state = %{board: board, castling_rights: %{}}
        assert KnightMoves.valid_move?(state, {:c, 3}, {:b, 1})
    end
end
