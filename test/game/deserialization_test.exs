defmodule Game.Deserialization.Test do

    use ExUnit.Case

    alias Game.Deserialization
    alias Game.Board

    test "FEN reverse to map for starting position" do
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
        assert Deserialization.decode_fen(fen) == %Board{}
    end
end
