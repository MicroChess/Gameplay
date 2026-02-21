defmodule KubeChess.Game.Rooks.Test do
    use ExUnit.Case

    alias KubeChess.Game.RookMoves

    test "Rook move ok [horizontal, a1 -> d1, no capture]" do
        squares = %{ {:a, 1} => {:rook, :white} }
        state = %{squares: squares}
        assert RookMoves.valid_move?(state, {:a, 1}, {:d, 1})
    end

    test "Rook move ok [horizontal, a1 -> d1, with capture]" do
        squares = %{ {:a, 1} => {:rook, :white}, {:d, 1} => {:pawn, :black} }
        state = %{squares: squares}
        assert RookMoves.valid_move?(state, {:a, 1}, {:d, 1})
    end

    test "Rook move ok [horizontal, a1 -> d1, with suicide]" do
        squares = %{ {:a, 1} => {:rook, :white}, {:d, 1} => {:pawn, :white} }
        state = %{squares: squares}
        assert not RookMoves.valid_move?(state, {:a, 1}, {:d, 1})
    end

    test "Rook move ok [horizontal, a1 -> d1, with jump]" do
        squares = %{ {:a, 1} => {:rook, :white}, {:c, 1} => {:pawn, :black} }
        state = %{squares: squares}
        assert not RookMoves.valid_move?(state, {:a, 1}, {:d, 1})
    end

    test "Rook move ok [vertical, a1 -> a4, no capture]" do
        squares = %{ {:a, 1} => {:rook, :white} }
        state = %{squares: squares}
        assert RookMoves.valid_move?(state, {:a, 1}, {:a, 4})
    end

    test "Rook move ok [vertical, a1 -> a4, with capture]" do
        squares = %{ {:a, 1} => {:rook, :white}, {:a, 4} => {:pawn, :black} }
        state = %{squares: squares}
        assert RookMoves.valid_move?(state, {:a, 1}, {:a, 4})
    end

    test "Rook move ok [vertical, a1 -> a4, with suicide]" do
        squares = %{ {:a, 1} => {:rook, :white}, {:a, 4} => {:pawn, :white} }
        state = %{squares: squares}
        assert not RookMoves.valid_move?(state, {:a, 1}, {:a, 4})
    end

    test "Rook move ok [vertical, a1 -> a4, with jump]" do
        squares = %{ {:a, 1} => {:rook, :white}, {:a, 3} => {:pawn, :black} }
        state = %{squares: squares}
        assert not RookMoves.valid_move?(state, {:a, 1}, {:a, 4})
    end
end
