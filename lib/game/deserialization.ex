defmodule Game.Deserialization do

    alias Game.Board

    @files [:a, :b, :c, :d, :e, :f, :g, :h]

    def decode_fen(fen) do
        [squares, turn, rights, en_passant, half, full] = String.split(fen, " ")
        %Board{
            squares: decode_squares(squares),
            castling_rights: decode_castling_rights(rights),
            counters: %{
                halfmoves: String.to_integer(half),
                fullmoves: String.to_integer(full),
            },
            white_king_location: find_king_location(decode_squares(squares), :white),
            black_king_location: find_king_location(decode_squares(squares), :black),
            en_passant_target: decode_en_passant_target(en_passant),
            turn: decode_turn(turn),
        }
    end

    defp decode_turn("w"), do: :white
    defp decode_turn("b"), do: :black

    defp find_king_location(squares, color) do
        is_king? = fn {_location, piece} -> piece == {:king, color} end
        case Enum.find(squares, is_king?) do
            {{file, rank}, _} -> {file, rank}
            nil -> nil
        end
    end

    defp decode_castling_rights(castling) do
        %{
            white_lx: String.contains?(castling, "Q"),
            white_sx: String.contains?(castling, "K"),
            black_lx: String.contains?(castling, "q"),
            black_sx: String.contains?(castling, "k")
        }
    end

    defp decode_en_passant_target("-"), do: nil
    defp decode_en_passant_target(str) do
        <<file_char::binary-size(1), rank_char::binary-size(1)>> = str
        file = String.to_atom(file_char)
        rank = String.to_integer(rank_char)
        {file, rank}
    end

    defp decode_squares(squares_text_section) do
        ranks = Enum.with_index(String.split(squares_text_section, "/"))
        for {rank_str, rank_idx} <- ranks,
            {file_idx, piece_char} <- decode_rank(rank_str),
        into: %{} do
            file = Enum.at(@files, file_idx)
            rank_num = 8 - rank_idx
            {{file, rank_num}, char_to_piece(piece_char)}
        end
    end

    defp decode_rank(str) do
        str |> String.graphemes()
            |> Enum.reduce({[], 0}, &decode_file/2)
            |> elem(0)
    end

    defp decode_file(char, {pieces, file_idx}) do
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
