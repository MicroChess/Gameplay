defmodule KubeChess.Game.Knights.Test do
    use ExUnit.Case

    alias KubeChess.Game.KnightMoves

    @files [:a, :b, :c, :d, :e, :f, :g, :h]
    @ranks [1, 2, 3, 4, 5, 6, 7, 8]

    test "knight move ok [L-shape, b1 -> c3, no capture]" do
        squares = %{ {:b, 1} => {:knight, :white} }
        state = %{squares: squares}
        assert KnightMoves.valid_move?(state, {:b, 1}, {:c, 3})
    end

    test "knight move ok [L-shape, c3 -> b1, no capture]" do
        squares = %{ {:c, 3} => {:knight, :white} }
        state = %{squares: squares}
        assert KnightMoves.valid_move?(state, {:c, 3}, {:b, 1})
    end

    test "knight move ok [L-shape, c3 -> b1, capture]" do
        squares = %{ {:c, 3} => {:knight, :white}, {:b, 1} => {:pawn, :black} }
        state = %{squares: squares}
        assert KnightMoves.valid_move?(state, {:c, 3}, {:b, 1})
    end

    test "knight move ok [L-shape, c3 -> b1, with suicide]" do
        squares = %{ {:c, 3} => {:knight, :white}, {:b, 1} => {:pawn, :white} }
        state = %{squares: squares}
        assert not KnightMoves.valid_move?(state, {:c, 3}, {:b, 1})
    end

    test "knight move ok [L-shape, c3 -> b1, with jump over opponents]" do
        squares = for f <- @files, r <- @ranks, into: %{} do
            {{f, r}, {:pawn, :black}}
        end
        squares = Map.put(squares, {:c, 3}, {:knight, :white})
        state = %{squares: squares}
        assert KnightMoves.valid_move?(state, {:c, 3}, {:b, 1})
    end

    test "knight move ok [L-shape, c3 -> b1, with over firends]" do
        squares = for f <- @files, r <- @ranks, into: %{} do
            {{f, r}, {:pawn, :white}}
        end
        squares = Map.put(squares, {:c, 3}, {:knight, :white})
        squares = Map.put(squares, {:b, 1}, {:rook, :black})
        state = %{squares: squares}
        assert KnightMoves.valid_move?(state, {:c, 3}, {:b, 1})
    end
end
