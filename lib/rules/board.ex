defmodule ClusterChess.Rules.Board do

    alias ClusterChess.Rules.KingMoves
    alias ClusterChess.Rules.QueenMoves
    alias ClusterChess.Rules.RookMoves
    alias ClusterChess.Rules.BishopMoves
    alias ClusterChess.Rules.PawnMoves
    alias ClusterChess.Rules.KnightMoves
    alias ClusterChess.Rules.MakeMoves

    defstruct [
        squares: %{},
        castling_rights: %{
            white_lx: true,
            white_sx: true,
            black_lx: true,
            black_sx: true
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
        case {legal_moves, in_check?} do
            {[], true}  -> :checkmate
            {[], false} -> :stalemate
            {mvs, true} -> checkmate?(board, color, mvs)
            _some_other -> :safe
        end
    end

    def checkmate?(board, color, all_legal_moves) do
        Enum.all?(all_legal_moves, fn {from, to} ->
            new_board = MakeMoves.apply_move(board, from, to)
            valid? = (new_board != :invalid_move)
            valid? and king_in_check?(new_board, color)
        end)
    end
end
