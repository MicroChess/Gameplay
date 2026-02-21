defmodule KubeChess.Game.Bishops.Test do
    use ExUnit.Case

    alias KubeChess.Game.BishopMoves

    test "bishop move ok [//, a1 -> d4, no capture]" do
        squares = %{ {:a, 1} => {:bishop, :white} }
        state = %{squares: squares}
        assert BishopMoves.valid_move?(state, {:a, 1}, {:d, 4})
    end

    test "bishop move ok [//, a1 -> d4, with capture]" do
        squares = %{ {:a, 1} => {:bishop, :white}, {:d, 4} => {:pawn, :black} }
        state = %{squares: squares}
        assert BishopMoves.valid_move?(state, {:a, 1}, {:d, 4})
    end

    test "bishop move ok [//, a1 -> d4, with suicide]" do
        squares = %{ {:a, 1} => {:bishop, :white}, {:d, 4} => {:pawn, :white} }
        state = %{squares: squares}
        assert not BishopMoves.valid_move?(state, {:a, 1}, {:d, 4})
    end

    test "bishop move ok [//, a1 -> d4, with jump]" do
        squares = %{ {:a, 1} => {:bishop, :white}, {:c, 3} => {:pawn, :black} }
        state = %{squares: squares}
        assert not BishopMoves.valid_move?(state, {:a, 1}, {:d, 4})
    end

    test "bishop move ok [\\, a1 <- d4, no capture]" do
        squares = %{ {:d, 4} => {:bishop, :black} }
        state = %{squares: squares}
        assert BishopMoves.valid_move?(state, {:d, 4}, {:a, 1})
    end

    test "bishop move ok [\\, a1 <- d4, with capture]" do
        squares = %{ {:a, 1} => {:pawn, :white}, {:d, 4} => {:bishop, :black} }
        state = %{squares: squares}
        assert BishopMoves.valid_move?(state, {:d, 4}, {:a, 1})
    end

    test "bishop move ok [\\, a1 <- d4, with suicide]" do
        squares = %{ {:a, 1} => {:pawn, :white}, {:d, 4} => {:bishop, :white} }
        state = %{squares: squares}
        assert not BishopMoves.valid_move?(state, {:d, 4}, {:a, 1})
    end

    test "bishop move ok [\\, a1 <- d4, with jump]" do
        squares = %{ {:b, 2} => {:pawn, :white}, {:d, 4} => {:bishop, :black} }
        state = %{squares: squares}
        assert not BishopMoves.valid_move?(state, {:d, 4}, {:a, 1})
    end
end
