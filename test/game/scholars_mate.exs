defmodule Game.ScholarsMate.Test do
    use ExUnit.Case

    alias Game.MakeMoves
    alias Game.Board

    @full_castling_rights %{
        white_lx: true,
        white_rx: true,
        black_lx: true,
        black_rx: true
    }

    @initial_position %{
        {:a, 1} => {:rook, :white},    {:a, 8} => {:rook, :black},
        {:b, 1} => {:knight, :white},  {:b, 8} => {:knight, :black},
        {:c, 1} => {:bishop, :white},  {:c, 8} => {:bishop, :black},
        {:d, 1} => {:queen, :white},   {:d, 8} => {:queen, :black},
        {:e, 1} => {:king, :white},    {:e, 8} => {:king, :black},
        {:f, 1} => {:bishop, :white},  {:f, 8} => {:bishop, :black},
        {:g, 1} => {:knight, :white},  {:g, 8} => {:knight, :black},
        {:h, 1} => {:rook, :white},    {:h, 8} => {:rook, :black},

        {:a, 2} => {:pawn, :white},    {:a, 7} => {:pawn, :black},
        {:b, 2} => {:pawn, :white},    {:b, 7} => {:pawn, :black},
        {:c, 2} => {:pawn, :white},    {:c, 7} => {:pawn, :black},
        {:d, 2} => {:pawn, :white},    {:d, 7} => {:pawn, :black},
        {:e, 2} => {:pawn, :white},    {:e, 7} => {:pawn, :black},
        {:f, 2} => {:pawn, :white},    {:f, 7} => {:pawn, :black},
        {:g, 2} => {:pawn, :white},    {:g, 7} => {:pawn, :black},
        {:h, 2} => {:pawn, :white},    {:h, 7} => {:pawn, :black},
    }

    def assert_expected_postmove_situation(board, color) do
        assert board != :invalid_move
        assert Board.king_status(board, :white) == :safe
        assert Board.king_status(board, :black) == :safe
        assert board.castling_rights == @full_castling_rights
        assert board.white_king_location == {:e, 1}
        assert board.black_king_location == {:e, 8}
        assert board.turn == color
    end

    test "board move ok [fullgame e2e, the scholar's mate]" do
        board = %{
            squares: @initial_position,
            turn: :white,
            en_passant_target: nil,
            castling_rights: @full_castling_rights,
            white_king_location: {:e, 1},
            black_king_location: {:e, 8},
            counters: %{ halfmoves: 0, fullmoves: 1 }
        }

        assert Board.king_status(board, :white) == :safe
        assert board.turn == :white

        m1 = MakeMoves.apply_move(board, {:e, 2}, {:e, 4})
        assert_expected_postmove_situation(m1, :black)
        assert m1.en_passant_target == {:e, 3}

        m2 = MakeMoves.apply_move(m1, {:e, 7}, {:e, 5})
        assert_expected_postmove_situation(m2, :white)
        assert m2.en_passant_target == {:e, 6}

        m3 = MakeMoves.apply_move(m2, {:d, 1}, {:h, 5})
        assert_expected_postmove_situation(m3, :black)
        assert m3.en_passant_target == nil

        m4 = MakeMoves.apply_move(m3, {:b, 8}, {:c, 6})
        assert_expected_postmove_situation(m4, :white)
        assert m4.en_passant_target == nil

        m5 = MakeMoves.apply_move(m4, {:f, 1}, {:c, 4})
        assert_expected_postmove_situation(m5, :black)
        assert m5.en_passant_target == nil

        m6 = MakeMoves.apply_move(m5, {:g, 8}, {:f, 6})
        assert_expected_postmove_situation(m6, :white)
        assert m6.en_passant_target == nil

        m7 = MakeMoves.apply_move(m6, {:h, 5}, {:f, 7})
        assert Board.king_status(m7, :white) == :safe
        assert Board.king_status(m7, :black) == :checkmate
        assert m7.en_passant_target == nil
    end
end
