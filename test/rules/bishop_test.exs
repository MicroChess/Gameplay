defmodule ClusterChess.Rules.Bishops.Test do
    use ExUnit.Case

    alias ClusterChess.Rules.BishopMoves

    test "bishop move ok [//, a1 -> d4, no capture]" do
        board = %{ {:a, 1} => {:bishop, :white} }
        state = %{board: board}
        assert BishopMoves.valid_move?(state, {:a, 1}, {:d, 4})
    end

    test "bishop move ok [//, a1 -> d4, with capture]" do
        board = %{ {:a, 1} => {:bishop, :white}, {:d, 4} => {:pawn, :black} }
        state = %{board: board}
        assert BishopMoves.valid_move?(state, {:a, 1}, {:d, 4})
    end

    test "bishop move ok [//, a1 -> d4, with suicide]" do
        board = %{ {:a, 1} => {:bishop, :white}, {:d, 4} => {:pawn, :white} }
        state = %{board: board}
        assert not BishopMoves.valid_move?(state, {:a, 1}, {:d, 4})
    end

    test "bishop move ok [//, a1 -> d4, with jump]" do
        board = %{ {:a, 1} => {:bishop, :white}, {:c, 3} => {:pawn, :black} }
        state = %{board: board}
        assert not BishopMoves.valid_move?(state, {:a, 1}, {:d, 4})
    end

    test "bishop move ok [\\, a1 <- d4, no capture]" do
        board = %{ {:d, 4} => {:bishop, :black} }
        state = %{board: board}
        assert BishopMoves.valid_move?(state, {:d, 4}, {:a, 1})
    end

    test "bishop move ok [\\, a1 <- d4, with capture]" do
        board = %{ {:a, 1} => {:pawn, :white}, {:d, 4} => {:bishop, :black} }
        state = %{board: board}
        assert BishopMoves.valid_move?(state, {:d, 4}, {:a, 1})
    end

    test "bishop move ok [\\, a1 <- d4, with suicide]" do
        board = %{ {:a, 1} => {:pawn, :white}, {:d, 4} => {:bishop, :white} }
        state = %{board: board}
        assert not BishopMoves.valid_move?(state, {:d, 4}, {:a, 1})
    end

    test "bishop move ok [\\, a1 <- d4, with jump]" do
        board = %{ {:b, 2} => {:pawn, :white}, {:d, 4} => {:bishop, :black} }
        state = %{board: board}
        assert not BishopMoves.valid_move?(state, {:d, 4}, {:a, 1})
    end
end
