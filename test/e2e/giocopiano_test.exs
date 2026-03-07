defmodule GiocoPiano.Test do
    use ExUnit.Case




    @white_can_castle     %{ white_lx: true, white_rx: true }
    @white_cannot_castle  %{ white_lx: false, white_rx: false }
    @black_can_castle     %{ black_lx: true, black_rx: true }
    @full_castling_rights Map.merge(@white_can_castle, @black_can_castle)
    @white_just_castled   Map.merge(@white_cannot_castle, @black_can_castle)

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
        assert Utilities.king_status(board, :white) == :safe
        assert Utilities.king_status(board, :black) == :safe
        assert board.castling_rights == @full_castling_rights
        assert board.white_king_location == {:e, 1}
        assert board.black_king_location == {:e, 8}
        assert board.turn == color
    end

    test "board move ok [fullgame e2e, the italian opening]" do
        board = %{
            squares: @initial_position,
            turn: :white,
            en_passant_target: nil,
            castling_rights: @full_castling_rights,
            white_king_location: {:e, 1},
            black_king_location: {:e, 8},
            counters: %{ halfmoves: 0, fullmoves: 1 }
        }

        assert Utilities.king_status(board, :white) == :safe
        assert board.turn == :white

        m1 = Board.apply_move!(board, {:e, 2}, {:e, 4})
        assert_expected_postmove_situation(m1, :black)
        assert m1.en_passant_target == {:e, 3}

        m2 = Board.apply_move!(m1, {:e, 7}, {:e, 5})
        assert_expected_postmove_situation(m2, :white)
        assert m2.en_passant_target == {:e, 6}

        m3 = Board.apply_move!(m2, {:g, 1}, {:f, 3})
        assert_expected_postmove_situation(m3, :black)
        assert m3.en_passant_target == nil

        m4 = Board.apply_move!(m3, {:g, 8}, {:f, 6})
        assert_expected_postmove_situation(m4, :white)
        assert m4.en_passant_target == nil

        m5 = Board.apply_move!(m4, {:f, 1}, {:c, 4})
        assert_expected_postmove_situation(m5, :black)
        assert m5.en_passant_target == nil

        m6 = Board.apply_move!(m5, {:b, 8}, {:c, 6})
        assert_expected_postmove_situation(m6, :white)
        assert m6.en_passant_target == nil

        m7 = Board.apply_move!(m6, {:e, 1}, {:g, 1})
        assert m7.en_passant_target == nil
        assert m7.white_king_location == {:g, 1}
        assert m7.squares[{:f, 1}] == {:rook, :white}
        assert m7.counters.halfmoves == 5
        assert m7.counters.fullmoves == 4
        assert m7.castling_rights == @white_just_castled
    end
end
