defmodule Game.Board.Test do
    use ExUnit.Case

    alias Game.MakeMoves

    @full_castling_rights %{
        white_lx: true,
        white_rx: true,
        black_lx: true,
        black_rx: true
    }

    test "board move ok [valid move, white turn, no special case]" do
        squares = %{ {:a, 2} => {:pawn, :white} }
        state = %{
            squares: squares,
            turn: :white,
            en_passant_target: nil,
            castling_rights: @full_castling_rights,
            white_king_location: nil,
            black_king_location: nil,
            counters: %{ halfmoves: 0, fullmoves: 1 }
        }
        assert MakeMoves.apply_move(state, {:a, 2}, {:a, 3}) != :invalid_move
        assert MakeMoves.apply_move(state, {:a, 2}, {:a, 3}).en_passant_target == nil
    end

    test "board move ok [valid move, white turn, erase existing en-passant]" do
        squares = %{ {:a, 2} => {:pawn, :white}, {:b, 4} => {:pawn, :white} }
        state = %{
            squares: squares,
            turn: :white,
            en_passant_target: {:b, 4},
            castling_rights: @full_castling_rights,
            white_king_location: nil,
            black_king_location: nil,
            counters: %{ halfmoves: 0, fullmoves: 1 }
        }
        assert MakeMoves.apply_move(state, {:a, 2}, {:a, 3}) != :invalid_move
        assert MakeMoves.apply_move(state, {:a, 2}, {:a, 3}).en_passant_target == nil
    end

    test "board move ok [valid move, white turn, make en-passant target]" do
        squares = %{ {:a, 2} => {:pawn, :white} }
        state = %{
            squares: squares,
            turn: :white,
            en_passant_target: nil,
            castling_rights: @full_castling_rights,
            white_king_location: nil,
            black_king_location: nil,
            counters: %{ halfmoves: 0, fullmoves: 1 }
        }
        assert MakeMoves.apply_move(state, {:a, 2}, {:a, 3}) != :invalid_move
        assert MakeMoves.apply_move(state, {:a, 2}, {:a, 4}).en_passant_target == {:a, 3}
    end

    test "board move ok [illegal move, too far away]" do
        squares = %{ {:a, 2} => {:pawn, :white} }
        state = %{
            squares: squares,
            turn: :white,
            en_passant_target: nil,
            castling_rights: @full_castling_rights,
            white_king_location: nil,
            black_king_location: nil,
            counters: %{ halfmoves: 0, fullmoves: 1 }
        }
        assert MakeMoves.apply_move(state, {:a, 2}, {:a, 8}) == :invalid_move
    end

    test "board move ok [valid move, white turn, castling]" do
        squares = %{ {:e, 1} => {:king, :white}, {:h, 1} => {:rook, :white} }
        state = %{
            squares: squares,
            turn: :white,
            en_passant_target: nil,
            castling_rights: @full_castling_rights,
            white_king_location: {:e, 1},
            black_king_location: nil,
            counters: %{ halfmoves: 0, fullmoves: 1 }
        }
        out = MakeMoves.apply_move(state, {:e, 1}, {:g, 1})
        assert out != :invalid_move
        assert out.castling_rights.white_lx == false
        assert out.castling_rights.white_rx == false
        assert out.castling_rights.black_lx == true
        assert out.castling_rights.black_rx == true
    end

    test "board move ok [valid move, white turn, invalidating castling rights]" do
        squares = %{ {:e, 1} => {:king, :white}, {:h, 1} => {:rook, :white} }
        state = %{
            squares: squares,
            turn: :white,
            en_passant_target: nil,
            castling_rights: @full_castling_rights,
            white_king_location: {:e, 1},
            black_king_location: nil,
            counters: %{ halfmoves: 0, fullmoves: 1 }
        }
        out = MakeMoves.apply_move(state, {:h, 1}, {:h, 3})
        assert out != :invalid_move
        assert out.castling_rights.white_lx == false
        assert out.castling_rights.white_rx == true
        assert out.castling_rights.black_lx == true
        assert out.castling_rights.black_rx == true
    end

    test "board move ok [wrong turn, white turn, but black is moving]" do
        squares = %{ {:a, 7} => {:pawn, :black} }
        state = %{
            squares: squares,
            turn: :white,
            en_passant_target: nil,
            castling_rights: @full_castling_rights,
            white_king_location: nil,
            black_king_location: nil,
            counters: %{ halfmoves: 0, fullmoves: 1 }
        }
        assert MakeMoves.apply_move(state, {:a, 7}, {:a, 6}) == :invalid_move
    end

    test "board move ok [black's turn, check turn after move]" do
        squares = %{ {:a, 7} => {:pawn, :black} }
        state = %{
            squares: squares,
            turn: :black,
            en_passant_target: nil,
            castling_rights: @full_castling_rights,
            white_king_location: nil,
            black_king_location: nil,
            counters: %{ halfmoves: 0, fullmoves: 1 }
        }
        assert MakeMoves.apply_move(state, {:a, 7}, {:a, 6}) != :invalid_move
        assert MakeMoves.apply_move(state, {:a, 7}, {:a, 6}).turn == :white
    end
end
