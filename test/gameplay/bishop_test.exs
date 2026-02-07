defmodule ClusterChess.Gameplay.Bishops.Test do
    use ExUnit.Case

    alias ClusterChess.Gameplay.Validator

    test "bishop move ok [//, a1 -> d4, no capture]" do
        board = %{ {:a, 1} => {:bishop, :white} }
        assert Validator.validate_move(board, {:a, 1}, {:d, 4})
    end

    test "bishop move ok [//, a1 -> d4, with capture]" do
        board = %{ {:a, 1} => {:bishop, :white}, {:d, 4} => {:pawn, :black} }
        assert Validator.validate_move(board, {:a, 1}, {:d, 4})
    end

    test "bishop move ok [//, a1 -> d4, with suicide]" do
        board = %{ {:a, 1} => {:bishop, :white}, {:d, 4} => {:pawn, :white} }
        assert not Validator.validate_move(board, {:a, 1}, {:d, 4})
    end

    test "bishop move ok [//, a1 -> d4, with jump]" do
        board = %{ {:a, 1} => {:bishop, :white}, {:c, 3} => {:pawn, :black} }
        assert not Validator.validate_move(board, {:a, 1}, {:d, 4})
    end

    test "bishop move ok [\\, a1 <- d4, no capture]" do
        board = %{ {:a, 1} => {:pawn, :white} }
        assert Validator.validate_move(board, {:d, 4}, {:a, 1})
    end

    test "bishop move ok [\\, a1 <- d4, with capture]" do
        board = %{ {:a, 1} => {:pawn, :white}, {:d, 4} => {:bishop, :black} }
        assert Validator.validate_move(board, {:d, 4}, {:a, 1})
    end

    test "bishop move ok [\\, a1 <- d4, with suicide]" do
        board = %{ {:a, 1} => {:pawn, :white}, {:d, 4} => {:bishop, :white} }
        assert not Validator.validate_move(board, {:d, 4}, {:a, 1})
    end

    test "bishop move ok [\\, a1 <- d4, with jump]" do
        board = %{ {:b, 2} => {:pawn, :white}, {:d, 4} => {:bishop, :black} }
        assert not Validator.validate_move(board, {:d, 4}, {:a, 1})
    end
end
