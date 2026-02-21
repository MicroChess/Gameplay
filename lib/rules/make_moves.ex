defmodule KubeChess.Rules.MakeMoves do

    alias KubeChess.Rules.Board
    alias KubeChess.Rules.Utilities
    alias KubeChess.Rules.KingMoves
    alias KubeChess.Rules.PawnMoves

    def apply_move(state, from, to) do
        cond do
            Utilities.color(state.squares, from) != state.turn -> :invalid_move
            PawnMoves.valid_en_passant?(state, from, to) -> apply_en_passant(state, from, to)
            KingMoves.valid_castling?(state, from, to) -> apply_castling(state, from, to)
            Board.valid_move?(state, from, to) -> apply_normal_move(state, from, to)
            true -> :invalid_move
        end
    end

    defp apply_castling(state, from, to) do
        {rook_from, rook_to} = case to do
            {:c, 1} -> {{:a, 1}, {:d, 1}}
            {:g, 1} -> {{:h, 1}, {:f, 1}}
            {:c, 8} -> {{:a, 8}, {:d, 8}}
            {:g, 8} -> {{:h, 8}, {:f, 8}}
        end
        %{state | turn: Utilities.opponent(state.turn)}
        |> apply_normal_move(from, to)
        |> apply_normal_move(rook_from, rook_to)
    end

    defp apply_en_passant(state, from, to) do
        new = Map.delete(state.squares, state.en_passant_target)
        tmp = %{state | squares: new}
        apply_normal_move(tmp, from, to)
    end

    defp apply_normal_move(state, from, to) do
        piece = Map.get(state.squares, from)
        new_squares = state.squares
        |> Map.delete(from)
        |> Map.put(to, piece)
        opponent = Utilities.opponent(state.turn)
        update_en_passant_target(state, from, to)
        |> update_castling_rights(from, to)
        |> update_king_location(from, to)
        |> Map.put(:squares, new_squares)
        |> Map.put(:turn, opponent)
    end

    defp update_en_passant_target(state, from, to) do
        square = Map.get(state.squares, from, {nil, nil})
        piece = elem(square, 0)
        distance = Utilities.vertical_distance(from, to)
        case {piece, distance} do
            {:pawn, 2}  -> %{state | en_passant_target: to}
            {:pawn, -2} -> %{state | en_passant_target: to}
            _some_other -> %{state | en_passant_target: nil}
        end
    end

    defp update_castling_rights(state, from, _to) do
        {piece, color} = Map.get(state.squares, from, {nil, nil})
        rights = state.castling_rights
        new_rights = case {piece, color, from} do
            {:king, :white, {:e, 1}} -> %{rights | white_kingside: false, white_queenside: false}
            {:rook, :white, {:a, 1}} -> %{rights | white_queenside: false}
            {:rook, :white, {:h, 1}} -> %{rights | white_kingside: false}
            {:king, :black, {:e, 8}} -> %{rights | black_kingside: false, black_queenside: false}
            {:rook, :black, {:a, 8}} -> %{rights | black_queenside: false}
            {:rook, :black, {:h, 8}} -> %{rights | black_kingside: false}
            _ -> rights
        end
        %{state | castling_rights: new_rights}
    end

    defp update_king_location(state, from, to) do
        {piece, color} = Map.get(state.squares, from, {nil, nil})
        case {piece, color} do
            {:king, :white} -> %{state | white_king_location: to}
            {:king, :black} -> %{state | black_king_location: to}
            _ -> state
        end
    end
end
