defmodule Game.MakeMoves do

    alias Game.Board
    alias Game.Utilities
    alias Game.KingMoves
    alias Game.PawnMoves
    alias Game.Utilities
    alias Game.MakeUpdates

    def apply_move(board, from, to, promotion \\ nil) do
        cond do
            Utilities.color(board.squares, from) != board.turn -> :invalid_move
            PawnMoves.valid_en_passant?(board, from, to) -> apply_en_passant(board, from, to)
            KingMoves.valid_castling?(board, from, to) -> apply_castling(board, from, to)
            Board.valid_move?(board, from, to) -> apply_normal_move(board, from, to)
            true -> :invalid_move
        end
    end

    def apply_castling(board, from, to) do
        board = MakeUpdates.update_all(board, from, to)
        color = Utilities.color(board.squares, from)
        {rook_from, rook_to} = case {color, to} do
            {:white, {:g, 1}} -> {{:h, 1}, {:f, 1}}
            {:white, {:c, 1}} -> {{:a, 1}, {:d, 1}}
            {:black, {:g, 8}} -> {{:h, 8}, {:f, 8}}
            {:black, {:c, 8}} -> {{:a, 8}, {:d, 8}}
        end
        squares = %{ board.squares | from => nil, rook_from => nil }
             |> Map.put(to, {:king, color})
             |> Map.put(rook_to, {:rook, color})
        %{ board | squares: squares }
    end

    def apply_en_passant(board, from, to) do
        board = MakeUpdates.update_all(board, from, to)
        piece = Map.get(board.squares, from)
        target = Utilities.shift(board, to, {0, 1})
        squares = Map.put(board.squares, to, piece)
            |> Map.delete(target)
            |> Map.delete(from)
        %{ board | squares: squares }
    end

    def apply_normal_move(board, from, to) do
        board = MakeUpdates.update_all(board, from, to)
        piece = Map.get(board.squares, from)
        squares = Map.put(board.squares, to, piece)
            |> Map.delete(from)
        %{ board | squares: squares }
    end

end
