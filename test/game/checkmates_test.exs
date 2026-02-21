defmodule KubeChess.Game.CheckMates.Test do
    use ExUnit.Case

    alias KubeChess.Game.Board

    @full_castling_rights %{
        white_kingside:  true,
        white_queenside: true,
        black_kingside:  true,
        black_queenside: true
    }

    test "board move ok [checkmate by knight]" do
        squares = %{
            {:h, 1} => {:king, :white},
            {:g, 1} => {:pawn, :white},
            {:g, 2} => {:pawn, :white},
            {:h, 2} => {:rook, :white},
            {:g, 3} => {:knight, :black},
        }
        state = %{
            squares: squares,
            turn: :white,
            en_passant_target: nil,
            castling_rights: @full_castling_rights,
            white_king_location: {:h, 1},
            black_king_location: nil
        }
        assert Board.king_status(state, :white) == :checkmate
    end

    test "board move ok [stalemate by double rook]" do
        squares = %{
            {:h, 1} => {:king, :white},
            {:g, 2} => {:rook, :black},
            {:g, 3} => {:rook, :black}
        }
        state = %{
            squares: squares,
            turn: :white,
            en_passant_target: nil,
            castling_rights: @full_castling_rights,
            white_king_location: {:h, 1},
            black_king_location: nil
        }
        assert Board.king_status(state, :white) == :stalemate
    end

    test "board move ok [safe because you can capture the rook]" do
        squares = %{
            {:h, 1} => {:king, :white},
            {:g, 2} => {:rook, :black}
        }
        state = %{
            squares: squares,
            turn: :white,
            en_passant_target: nil,
            castling_rights: @full_castling_rights,
            white_king_location: {:h, 1},
            black_king_location: nil
        }
        assert Board.king_status(state, :white) == :safe
    end

    test "board move ok [safe because you can push the pawn]" do
        squares = %{
            {:h, 1} => {:king, :white},
            {:g, 2} => {:rook, :black},
            {:g, 3} => {:rook, :black},
            {:a, 2} => {:pawn, :white}
        }
        state = %{
            squares: squares,
            turn: :white,
            en_passant_target: nil,
            castling_rights: @full_castling_rights,
            white_king_location: {:h, 1},
            black_king_location: nil
        }
        assert Board.king_status(state, :white) == :safe
    end
end
