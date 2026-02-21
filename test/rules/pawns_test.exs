defmodule KubeChess.Game.Pawns.Test do
    use ExUnit.Case

    alias KubeChess.Game.PawnMoves

    test "pawn move ok [push, a2 -> a3, no capture]" do
        squares = %{ {:a, 2} => {:pawn, :white} }
        state = %{squares: squares, en_passant_target: nil}
        assert PawnMoves.valid_move?(state, {:a, 2}, {:a, 3})
    end

    test "pawn move ok [double push, a2 -> a4, no capture]" do
        squares = %{ {:a, 2} => {:pawn, :white} }
        state = %{squares: squares, en_passant_target: nil}
        assert PawnMoves.valid_move?(state, {:a, 2}, {:a, 4})
    end

    test "pawn move ok [push, a2 -> a3, with suicide]" do
        squares = %{ {:a, 2} => {:pawn, :white}, {:a, 3} => {:pawn, :white} }
        state = %{squares: squares, en_passant_target: nil}
        assert not PawnMoves.valid_move?(state, {:a, 2}, {:a, 3})
    end

    test "pawn move ok [push, a2 -> a4, with jump]" do
        squares = %{ {:a, 2} => {:pawn, :white}, {:a, 3} => {:pawn, :black} }
        state = %{squares: squares, en_passant_target: nil}
        assert not PawnMoves.valid_move?(state, {:a, 2}, {:a, 4})
    end

    test "pawn capture ok [capture, a2 -> b3]" do
        squares = %{ {:a, 2} => {:pawn, :white}, {:b, 3} => {:pawn, :black} }
        state = %{squares: squares, en_passant_target: nil}
        assert PawnMoves.valid_move?(state, {:a, 2}, {:b, 3})
    end

    test "pawn capture fail [capture, a2 -> b3, with suicide]" do
        squares = %{ {:a, 2} => {:pawn, :white}, {:b, 3} => {:pawn, :white} }
        state = %{squares: squares, en_passant_target: nil}
        assert not PawnMoves.valid_move?(state, {:a, 2}, {:b, 3})
    end

    test "pawn capture too far [capture, a2 -> c4, too far]" do
        squares = %{ {:a, 2} => {:pawn, :white}, {:c, 4} => {:pawn, :black} }
        state = %{squares: squares, en_passant_target: nil}
        assert not PawnMoves.valid_move?(state, {:a, 2}, {:c, 4})
    end
end
