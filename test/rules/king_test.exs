defmodule KubeChess.Rules.King.Test do
    use ExUnit.Case

    alias KubeChess.Rules.KingMoves

    test "king move ok [push, a2 -> a3, no capture]" do
        squares = %{ {:a, 2} => {:king, :white} }
        state = %{squares: squares, castling_rights: %{}}
        assert KingMoves.valid_move?(state, {:a, 2}, {:a, 3})
    end

    test "king move ok [push, b2 -> b3, with capture]" do
        squares = %{ {:b, 2} => {:king, :white}, {:b, 3} => {:pawn, :black} }
        state = %{squares: squares, castling_rights: %{}}
        assert KingMoves.valid_move?(state, {:b, 2}, {:b, 3})
    end

    test "king move ok [push, b2 -> b3, with suicide]" do
        squares = %{ {:b, 2} => {:king, :white}, {:b, 3} => {:pawn, :white} }
        state = %{squares: squares, castling_rights: %{}}
        assert not KingMoves.valid_move?(state, {:b, 2}, {:b, 3})
    end

    test "king move ok [push, b2 -> b4, too long]" do
        squares = %{ {:b, 2} => {:king, :white} }
        state = %{squares: squares, castling_rights: %{}}
        assert not KingMoves.valid_move?(state, {:b, 2}, {:b, 4})
    end

    test "king move ok [push, queenside castling, no checks, white]" do
        squares = %{ {:e, 1} => {:king, :white} }
        state = %{squares: squares, castling_rights: %{white_queenside: true}}
        assert KingMoves.valid_move?(state, {:e, 1}, {:c, 1})
    end

    test "king move ok [push, queenside castling, forbidden]" do
        squares = %{ {:e, 1} => {:king, :white} }
        state = %{squares: squares, castling_rights: %{white_queenside: false}}
        assert not KingMoves.valid_move?(state, {:e, 1}, {:c, 1})
    end

    test "king move ok [push, queenside castling, with check]" do
        squares = %{ {:e, 1} => {:king, :white}, {:d, 2} => {:rook, :black} }
        state = %{squares: squares, castling_rights: %{white_queenside: true}}
        assert not KingMoves.valid_move?(state, {:e, 1}, {:c, 1})
    end

    test "king move ok [push, queenside castling, with check 2]" do
        squares = %{ {:e, 1} => {:king, :white}, {:b, 2} => {:rook, :black} }
        state = %{squares: squares, castling_rights: %{white_queenside: true}}
        assert KingMoves.valid_move?(state, {:e, 1}, {:c, 1})
    end
end
