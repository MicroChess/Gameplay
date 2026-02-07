defmodule ClusterChess.Gameplay.Fen.Test do

    use ExUnit.Case

    test "FEN parsing of the starting position" do
        board = %{
            {:a, 8} => {:rook, :black},   {:b, 8} => {:knight, :black}, {:c, 8} => {:bishop, :black}, {:d, 8} => {:queen, :black},
            {:e, 8} => {:king, :black},   {:f, 8} => {:bishop, :black}, {:g, 8} => {:knight, :black}, {:h, 8} => {:rook, :black},
            {:a, 7} => {:pawn, :black},   {:b, 7} => {:pawn, :black},   {:c, 7} => {:pawn, :black},   {:d, 7} => {:pawn, :black},
            {:e, 7} => {:pawn, :black},   {:f, 7} => {:pawn, :black},   {:g, 7} => {:pawn, :black},   {:h, 7} => {:pawn, :black},
            {:a, 2} => {:pawn, :white},   {:b, 2} => {:pawn, :white},   {:c, 2} => {:pawn, :white},   {:d, 2} => {:pawn, :white},
            {:e, 2} => {:pawn, :white},   {:f, 2} => {:pawn, :white},   {:g, 2} => {:pawn, :white},   {:h, 2} => {:pawn, :white},
            {:a, 1} => {:rook, :white},   {:b, 1} => {:knight, :white}, {:c, 1} => {:bishop, :white}, {:d, 1} => {:queen, :white},
            {:e, 1} => {:king, :white},   {:f, 1} => {:bishop, :white}, {:g, 1} => {:knight, :white}, {:h, 1} => {:rook, :white}
        }
        fen = ClusterChess.Gameplay.FenEncoding.map_to_fen(board, :white)
        assert fen == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w"
    end

    test "FEN reverse to map for starting position" do
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w"
        board = ClusterChess.Gameplay.FenDecoding.fen_to_map(fen)
        reference = %{
            {:a, 8} => {:rook, :black},   {:b, 8} => {:knight, :black}, {:c, 8} => {:bishop, :black}, {:d, 8} => {:queen, :black},
            {:e, 8} => {:king, :black},   {:f, 8} => {:bishop, :black}, {:g, 8} => {:knight, :black}, {:h, 8} => {:rook, :black},
            {:a, 7} => {:pawn, :black},   {:b, 7} => {:pawn, :black},   {:c, 7} => {:pawn, :black},   {:d, 7} => {:pawn, :black},
            {:e, 7} => {:pawn, :black},   {:f, 7} => {:pawn, :black},   {:g, 7} => {:pawn, :black},   {:h, 7} => {:pawn, :black},
            {:a, 2} => {:pawn, :white},   {:b, 2} => {:pawn, :white},   {:c, 2} => {:pawn, :white},   {:d, 2} => {:pawn, :white},
            {:e, 2} => {:pawn, :white},   {:f, 2} => {:pawn, :white},   {:g, 2} => {:pawn, :white},   {:h, 2} => {:pawn, :white},
            {:a, 1} => {:rook, :white},   {:b, 1} => {:knight, :white}, {:c, 1} => {:bishop, :white}, {:d, 1} => {:queen, :white},
            {:e, 1} => {:king, :white},   {:f, 1} => {:bishop, :white}, {:g, 1} => {:knight, :white}, {:h, 1} => {:rook, :white}
        }
        assert board == reference
    end
end
