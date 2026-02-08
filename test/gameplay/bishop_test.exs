defmodule ClusterChess.Gameplay.Bishops.Test do
    use ExUnit.Case

    alias ClusterChess.Gameplay.Validation

    test "bishop move ok [//, a1 -> d4, no capture]" do
        board = %{ {:a, 1} => {:bishop, :white} }
        assert Validation.validate_move(board, {:a, 1}, {:d, 4})
    end

    test "bishop move ok [//, a1 -> d4, with capture]" do
        board = %{ {:a, 1} => {:bishop, :white}, {:d, 4} => {:pawn, :black} }
        assert Validation.validate_move(board, {:a, 1}, {:d, 4})
    end

    test "bishop move ok [//, a1 -> d4, with suicide]" do
        board = %{ {:a, 1} => {:bishop, :white}, {:d, 4} => {:pawn, :white} }
        assert not Validation.validate_move(board, {:a, 1}, {:d, 4})
    end

    test "bishop move ok [//, a1 -> d4, with jump]" do
        board = %{ {:a, 1} => {:bishop, :white}, {:c, 3} => {:pawn, :black} }
        assert not Validation.validate_move(board, {:a, 1}, {:d, 4})
    end

    test "bishop move ok [\\, a1 <- d4, no capture]" do
        board = %{ {:a, 1} => {:pawn, :white} }
        assert Validation.validate_move(board, {:d, 4}, {:a, 1})
    end

    test "bishop move ok [\\, a1 <- d4, with capture]" do
        board = %{ {:a, 1} => {:pawn, :white}, {:d, 4} => {:bishop, :black} }
        assert Validation.validate_move(board, {:d, 4}, {:a, 1})
    end

    test "bishop move ok [\\, a1 <- d4, with suicide]" do
        board = %{ {:a, 1} => {:pawn, :white}, {:d, 4} => {:bishop, :white} }
        assert not Validation.validate_move(board, {:d, 4}, {:a, 1})
    end

    test "bishop move ok [\\, a1 <- d4, with jump]" do
        board = %{ {:b, 2} => {:pawn, :white}, {:d, 4} => {:bishop, :black} }
        assert not Validation.validate_move(board, {:d, 4}, {:a, 1})
    end
end
