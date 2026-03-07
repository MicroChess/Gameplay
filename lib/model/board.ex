defmodule Board do

    defstruct [
        squares: Squares.default(),
        castling_rights: %{
            white_lx: true,
            white_rx: true,
            black_lx: true,
            black_rx: true
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

    def apply_move!(board, from, to, promotion \\ nil) do
        squares = board.squares
        cond do
            Squares.color(squares, from) != board.turn   -> :invalid_move
            BishopMoves.valid_move?(board, from, to)     -> BishopMoves.apply_move!(board, from, to)
            QueenMoves.valid_move?(board, from, to)      -> QueenMoves.apply_move!(board, from, to)
            KnightMoves.valid_move?(board, from, to)     -> KnightMoves.apply_move!(board, from, to)
            KingMoves.valid_move?(board, from, to)       -> KingMoves.apply_move!(board, from, to)
            PawnMoves.valid_final_push?(board, from, to) -> PawnMoves.promote!(board, from, to, promotion)
            PawnMoves.valid_move?(board, from, to)       -> PawnMoves.apply_move!(board, from, to)
            RookMoves.valid_move?(board, from, to)       -> RookMoves.apply_move!(board, from, to)
            true -> :invalid_move
        end
    end
end
