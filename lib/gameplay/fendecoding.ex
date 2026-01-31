defmodule ClusterChess.Gameplay.FenDecoding do

    @files [:a, :b, :c, :d, :e, :f, :g, :h]

    def fen_to_map(fen) do
        [placement | _] = String.split(fen, " ")
        ranks = Enum.with_index(String.split(placement, "/"))
        for {rank_str, rank_idx} <- ranks,
            rank_num = 8 - rank_idx,
            {file_idx, piece_char} <- expand_rank(rank_str),
            file = Enum.at(@files, file_idx),
            into: %{} do
            {{file, rank_num}, char_to_piece(piece_char)}
        end
    end

    defp expand_rank(rank_str) do
        rank_str
        |> String.graphemes()
        |> Enum.reduce({[], 0}, fn char, {pieces, file_idx} ->
            case Integer.parse(char) do
                {n, _binary_remainder} -> {pieces, file_idx + n}
                :error -> {[{file_idx, char} | pieces], file_idx + 1}
            end
        end)
        |> elem(0)
        |> Enum.reverse()
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

    def char_to_turn("w"), do: :white
    def char_to_turn("b"), do: :black
end
