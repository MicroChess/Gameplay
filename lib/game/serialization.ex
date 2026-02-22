defmodule Game.Serialization do

    @files [:a, :b, :c, :d, :e, :f, :g, :h]

    def encode_fen(board) do
        discard_empty = fn txt -> txt != "" end
        sections = [
            encode_squares(board),
            encode_turn(board.turn),
            encode_castling_rights(board),
            encode_en_passant_target(board),
            Integer.to_string(board.counters.halfmoves),
            Integer.to_string(board.counters.fullmoves)
        ]
        Enum.filter(sections, discard_empty) |> Enum.join(" ")
    end

    defp encode_en_passant_target(board) do
        case board.en_passant_target do
            nil -> "-"
            {file, rank} -> "#{file}#{rank}"
        end
    end

    defp encode_squares(board) do
        encode_one_square = fn {file, rank} ->
            Map.get(board.squares, {file, rank})
            |> encode_piece_and_color()
        end
        ranks = for rank <- 8..1//-1 do
            for file <- @files do {file, rank} end
            |> Enum.map(encode_one_square)
            |> Enum.chunk_by(& &1)
            |> Enum.map(&runlength/1)
            |> Enum.concat()
            |> Enum.join("")
        end
        Enum.join(ranks, "/")
    end

    defp encode_castling_rights(board),
        do: if(board.castling_rights.white_sx, do: "K", else: "")
        <>  if(board.castling_rights.white_lx, do: "Q", else: "")
        <>  if(board.castling_rights.black_sx, do: "k", else: "")
        <>  if(board.castling_rights.black_lx, do: "q", else: "")

    defp runlength([nil] ++ tail), do: [Integer.to_string(1 + length(tail))]
    defp runlength(other), do: other

    def encode_piece_and_color(nil), do: nil
    def encode_piece_and_color({piece, color}) do
        letter_encoding = case piece do
            :pawn   -> "P"
            :rook   -> "R"
            :knight -> "N"
            :bishop -> "B"
            :queen  -> "Q"
            :king   -> "K"
        end
        case color do
            :white -> letter_encoding
            :black -> String.downcase(letter_encoding)
        end
    end

    defp encode_turn(:white), do: "w"
    defp encode_turn(:black), do: "b"

end
