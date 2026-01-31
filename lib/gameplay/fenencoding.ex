defmodule ClusterChess.Gameplay.FenEncoding do

    def map_to_fen(board, turn) do
        ranks = for rank <- 8..1//-1 do
            files = for file <- [:a, :b, :c, :d, :e, :f, :g, :h, :end] do
                case file do
                    :end -> "/"
                    _ -> Map.get(board, {file, rank}) |> piece_to_char()
                end
            end
            files |> Enum.chunk_by(& &1) |> Enum.map(&runlength/1) |> Enum.concat()
        end
        fen = Enum.join(ranks, "") |> String.trim_trailing()
        fen <> " " <> char_to_turn(turn)
    end

    defp runlength([nil] ++ tail), do: [Integer.to_string(1 + length(tail))]
    defp runlength([nil]), do: ["1"]
    defp runlength(other), do: other

    def piece_to_char(nil), do: nil
    def piece_to_char({piece, color}) do
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

    defp char_to_turn(:white), do: "w"
    defp char_to_turn(:black), do: "b"
end
