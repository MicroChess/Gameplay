defmodule KubeChess.Match.Fen do

    @files [:a, :b, :c, :d, :e, :f, :g, :h]

    def map_to_fen(board, turn) do
        ranks = for rank <- 8..1//-1 do
            files = for file <- @files do
                Map.get(board, {file, rank}) |> piece_to_char()
            end
            files |> Enum.chunk_by(& &1) |> Enum.map(&runlength/1) |> Enum.concat()
        end
        Enum.join(ranks, "/") <> " " <> char_to_turn(turn)
    end

    defp runlength([nil] ++ tail), do: [Integer.to_string(1 + length(tail))]
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

    def fen_to_map(fen) do
        [placement | _] = String.split(fen, " ")
        ranks = Enum.with_index(String.split(placement, "/"))
        for {rank_str, rank_idx} <- ranks,
            {file_idx, piece_char} <- parse_rank(rank_str),
        into: %{} do
            file = Enum.at(@files, file_idx)
            rank_num = 8 - rank_idx
            {{file, rank_num}, char_to_piece(piece_char)}
        end
    end

    defp parse_rank(str) do
        str |> String.graphemes()
            |> Enum.reduce({[], 0}, &reduce_rank/2)
            |> elem(0)
    end

    defp reduce_rank(char, {pieces, file_idx}) do
        case Integer.parse(char) do
            {n, _} -> {pieces, file_idx + n}
            _ -> {pieces ++ [{file_idx, char}], file_idx + 1}
        end
    end

    def char_to_piece(char) do
        color = if char =~ ~r/[A-Z]/,
            do: :white,
            else: :black
        type = case String.downcase(char) do
            "p" -> :pawn
            "r" -> :rook
            "n" -> :knight
            "b" -> :bishop
            "q" -> :queen
            "k" -> :king
        end
        {type, color}
    end
end
