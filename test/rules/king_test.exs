defmodule ClusterChess.Rules.King.Test do
    use ExUnit.Case

    alias ClusterChess.Rules.KingMoves

    test "king move ok [push, a2 -> a3, no capture]" do
        board = %{ {:a, 2} => {:king, :white} }
        state = %{board: board, castling_rights: %{}}
        assert KingMoves.valid_move?(state, {:a, 2}, {:a, 3})
    end

    test "king move ok [push, b2 -> b3, with capture]" do
        board = %{ {:b, 2} => {:king, :white}, {:b, 3} => {:pawn, :black} }
        state = %{board: board, castling_rights: %{}}
        assert KingMoves.valid_move?(state, {:b, 2}, {:b, 3})
    end

    test "king move ok [push, b2 -> b3, with suicide]" do
        board = %{ {:b, 2} => {:king, :white}, {:b, 3} => {:pawn, :white} }
        state = %{board: board, castling_rights: %{}}
        assert not KingMoves.valid_move?(state, {:b, 2}, {:b, 3})
    end

    test "king move ok [push, b2 -> b4, too long]" do
        board = %{ {:b, 2} => {:king, :white} }
        state = %{board: board, castling_rights: %{}}
        assert not KingMoves.valid_move?(state, {:b, 2}, {:b, 4})
    end

    test "king move ok [push, queenside castling, no checks, white]" do
        board = %{ {:e, 1} => {:king, :white} }
        state = %{board: board, castling_rights: %{white_queenside: true}}
        assert KingMoves.valid_move?(state, {:e, 1}, {:c, 1})
    end

    test "king move ok [push, queenside castling, forbidden]" do
        board = %{ {:e, 1} => {:king, :white} }
        state = %{board: board, castling_rights: %{white_queenside: false}}
        assert not KingMoves.valid_move?(state, {:e, 1}, {:c, 1})
    end

    test "king move ok [push, queenside castling, with check]" do
        board = %{ {:e, 1} => {:king, :white}, {:d, 2} => {:rook, :black} }
        state = %{board: board, castling_rights: %{white_queenside: true}}
        assert not KingMoves.valid_move?(state, {:e, 1}, {:c, 1})
    end

    test "king move ok [push, queenside castling, with check 2]" do
        board = %{ {:e, 1} => {:king, :white}, {:b, 2} => {:rook, :black} }
        state = %{board: board, castling_rights: %{white_queenside: true}}
        assert KingMoves.valid_move?(state, {:e, 1}, {:c, 1})
    end
end
