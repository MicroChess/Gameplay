defmodule ClusterChess.Gameplay.FenDecoding do

    @files [:a, :b, :c, :d, :e, :f, :g, :h]

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
