defmodule Game.Serialization.Test do

    use ExUnit.Case

    alias Game.Board
    alias Game.Serialization

    test "FEN parsing of the starting position" do
        fen = Serialization.encode_fen(%Board{})
        assert fen == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    end
end
