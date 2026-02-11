defmodule ClusterChess.Gameplay.Rooks.Test do
    use ExUnit.Case

    alias ClusterChess.Rules.RookMoves

    test "Rook move ok [horizontal, a1 -> d1, no capture]" do
        board = %{ {:a, 1} => {:rook, :white} }
        state = %{board: board, castling_rights: %{}}
        assert RookMoves.valid_move?(state, {:a, 1}, {:d, 1})
    end

    test "Rook move ok [horizontal, a1 -> d1, with capture]" do
        board = %{ {:a, 1} => {:rook, :white}, {:d, 1} => {:pawn, :black} }
        state = %{board: board, castling_rights: %{}}
        assert RookMoves.valid_move?(state, {:a, 1}, {:d, 1})
    end

    test "Rook move ok [horizontal, a1 -> d1, with suicide]" do
        board = %{ {:a, 1} => {:rook, :white}, {:d, 1} => {:pawn, :white} }
        state = %{board: board, castling_rights: %{}}
        assert not RookMoves.valid_move?(state, {:a, 1}, {:d, 1})
    end

    test "Rook move ok [horizontal, a1 -> d1, with jump]" do
        board = %{ {:a, 1} => {:rook, :white}, {:c, 1} => {:pawn, :black} }
        state = %{board: board, castling_rights: %{}}
        assert not RookMoves.valid_move?(state, {:a, 1}, {:d, 1})
    end

    test "Rook move ok [vertical, a1 -> a4, no capture]" do
        board = %{ {:a, 1} => {:rook, :white} }
        state = %{board: board, castling_rights: %{}}
        assert RookMoves.valid_move?(state, {:a, 1}, {:a, 4})
    end

    test "Rook move ok [vertical, a1 -> a4, with capture]" do
        board = %{ {:a, 1} => {:rook, :white}, {:a, 4} => {:pawn, :black} }
        state = %{board: board, castling_rights: %{}}
        assert RookMoves.valid_move?(state, {:a, 1}, {:a, 4})
    end

    test "Rook move ok [vertical, a1 -> a4, with suicide]" do
        board = %{ {:a, 1} => {:rook, :white}, {:a, 4} => {:pawn, :white} }
        state = %{board: board, castling_rights: %{}}
        assert not RookMoves.valid_move?(state, {:a, 1}, {:a, 4})
    end

    test "Rook move ok [vertical, a1 -> a4, with jump]" do
        board = %{ {:a, 1} => {:rook, :white}, {:a, 3} => {:pawn, :black} }
        state = %{board: board, castling_rights: %{}}
        assert not RookMoves.valid_move?(state, {:a, 1}, {:a, 4})
    end
end
