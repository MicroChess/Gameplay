defmodule Deserialization.Test do

    use ExUnit.Case

    test "FEN reverse to map for starting position" do
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
        assert Encoding.decode_fen(fen) == %Board{}
    end
end
