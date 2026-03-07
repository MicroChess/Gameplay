defmodule Serialization.Test do

    use ExUnit.Case





    @starting "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    @italian  "r1bqkb1r/pppp1ppp/2n2n2/4p3/2B1P3/5N2/PPPP1PPP/RNBQ1RK1 b kq - 5 4"
    @sicilian "rnbqkbnr/pp2pppp/3p4/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 0 3"

    test "FEN parsing of the starting position" do
        fen = Serialization.encode_fen(%Board{})
        assert fen == @starting
    end

    test "FEN reverse to map for starting position" do
        assert Deserialization.decode_fen(@starting) == %Board{}
    end

    test "FEN parsing of the italian opening" do
        board   = Deserialization.decode_fen(@italian)
        assert board.squares[{:e, 4}] == {:pawn, :white}
        assert board.squares[{:g, 1}] == {:king, :white}
        assert board.squares[{:f, 1}] == {:rook, :white}
        assert board.squares[{:e, 1}] == nil
        decoded = Serialization.encode_fen(board)
        assert @italian == decoded
    end

    test "FEN parsing of the sicilian defense" do
        board   = Deserialization.decode_fen(@sicilian)
        assert board.squares[{:e, 4}] == {:pawn, :white}
        assert board.squares[{:c, 5}] == {:pawn, :black}
        decoded = Serialization.encode_fen(board)
        assert @sicilian == decoded
    end
end
