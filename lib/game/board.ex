defmodule KubeChess.Game.Board do

    alias KubeChess.Game.KingMoves
    alias KubeChess.Game.QueenMoves
    alias KubeChess.Game.RookMoves
    alias KubeChess.Game.BishopMoves
    alias KubeChess.Game.PawnMoves
    alias KubeChess.Game.KnightMoves
    alias KubeChess.Game.MakeMoves

    defstruct [
        squares: %{
             {:a, 1} => {:rook,   :white}, {:a, 2} => {:pawn, :white},
             {:b, 1} => {:knight, :white}, {:c, 2} => {:pawn, :white},
             {:c, 1} => {:bishop, :white}, {:e, 2} => {:pawn, :white},
             {:d, 1} => {:queen,  :white}, {:g, 2} => {:pawn, :white},
             {:e, 1} => {:king,   :white}, {:b, 2} => {:pawn, :white},
             {:f, 1} => {:bishop, :white}, {:d, 2} => {:pawn, :white},
             {:g, 1} => {:knight, :white}, {:f, 2} => {:pawn, :white},
             {:h, 1} => {:rook,   :white}, {:h, 2} => {:pawn, :white},
             {:a, 8} => {:rook,   :black}, {:a, 7} => {:pawn, :black},
             {:b, 8} => {:knight, :black}, {:c, 7} => {:pawn, :black},
             {:c, 8} => {:bishop, :black}, {:e, 7} => {:pawn, :black},
             {:d, 8} => {:queen,  :black}, {:g, 7} => {:pawn, :black},
             {:e, 8} => {:king,   :black}, {:b, 7} => {:pawn, :black},
             {:f, 8} => {:bishop, :black}, {:d, 7} => {:pawn, :black},
             {:g, 8} => {:knight, :black}, {:f, 7} => {:pawn, :black},
             {:h, 8} => {:rook,   :black}, {:h, 7} => {:pawn, :black},
        },
        castling_rights: %{
            white_lx: true,
            white_sx: true,
            black_lx: true,
            black_sx: true
        },
        counters: %{
            halfmoves: 0,
            fullmoves: 1
        },
        white_king_location: {:e, 1},
        black_king_location: {:e, 8},
        en_passant_target: nil,
        turn: :white
    ]

    def valid_move?(state, from, to) do
        case Map.get(state.squares, from) do
            {:king, _color}   -> KingMoves.valid_move?(state, from, to)
            {:queen, _color}  -> QueenMoves.valid_move?(state, from, to)
            {:rook, _color}   -> RookMoves.valid_move?(state, from, to)
            {:bishop, _color} -> BishopMoves.valid_move?(state, from, to)
            {:pawn, _color}   -> PawnMoves.valid_move?(state, from, to)
            {:knight, _color} -> KnightMoves.valid_move?(state, from, to)
            _empty_nil_square -> false
        end
    end

    def legal_moves(state, from) do
        case Map.get(state.squares, from) do
            {:king, _color}   -> KingMoves.legal_moves(state, from)
            {:queen, _color}  -> QueenMoves.legal_moves(state, from)
            {:rook, _color}   -> RookMoves.legal_moves(state, from)
            {:bishop, _color} -> BishopMoves.legal_moves(state, from)
            {:pawn, _color}   -> PawnMoves.legal_moves(state, from)
            {:knight, _color} -> KnightMoves.legal_moves(state, from)
            _empty_nil_square -> false
        end
    end

    def all_legal_moves(state, target_color) do
        for {square, {_, piece_color}} <- state.squares,
            target_color == piece_color,
            to <- legal_moves(state, square),
        do: {square, to}
    end

    def king_location(board, color) do
        case color do
            :white -> board.white_king_location
            :black -> board.black_king_location
        end
    end

    def enemies(state, friendly_color) do
        for {enemy, {_, color}} <- state.squares,
            color not in [nil, friendly_color], do: enemy
    end

    def allies(state, friendly_color) do
        for {ally, {_, color}} <- state.squares,
            color == friendly_color, do: ally
    end

    def king_in_check?(board, color) do
        king_loc = king_location(board, color)
        enemies = enemies(board, color)
        Enum.any?(enemies, fn enemy ->
            valid_move?(board, enemy, king_loc)
        end)
    end

    def king_status(board, color) do
        legal_moves = all_legal_moves(board, color)
        in_check? = king_in_check?(board, color)
        all_checks = all_moves_bring_to_check?(board, color, legal_moves)
        case {all_checks, in_check?} do
            {true, true}  -> :checkmate
            {true, false} -> :stalemate
            _some_other -> :safe
        end
    end

    defp all_moves_bring_to_check?(board, color, all_legal_moves) do
        Enum.all?(all_legal_moves, fn {from, to} ->
            new_board = MakeMoves.apply_move(board, from, to)
            valid? = (new_board != :invalid_move)
            valid? and king_in_check?(new_board, color)
        end)
    end
end
