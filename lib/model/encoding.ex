defmodule Encoding do

    @files [:a, :b, :c, :d, :e, :f, :g, :h]
    @pieces %{"p" => :pawn, "r" => :rook, "n" => :knight, "b" => :bishop, "q" => :queen, "k" => :king}
    @letters Map.new(@pieces, fn {l, p} -> {p, String.upcase(l)} end)

    def encode_fen(board) do
        [encode_squares(board), encode_turn(board.turn), encode_castling_rights(board),
         encode_en_passant_target(board),
         Integer.to_string(board.counters.halfmoves),
         Integer.to_string(board.counters.fullmoves)]
        |> Enum.reject(&(&1 == ""))
        |> Enum.join(" ")
    end

    def decode_fen(fen) do
        [squares, turn, rights, en_passant, half, full] = String.split(fen, " ")
        decoded_squares = decode_squares(squares)
        %Board{
            squares:             decoded_squares,
            castling_rights:     decode_castling_rights(rights),
            counters:            %{halfmoves: String.to_integer(half), fullmoves: String.to_integer(full)},
            white_king_location: find_king_location(decoded_squares, :white),
            black_king_location: find_king_location(decoded_squares, :black),
            en_passant_target:   decode_en_passant_target(en_passant),
            turn:                decode_turn(turn),
        }
    end

    defp encode_turn(:white), do: "w"
    defp encode_turn(:black), do: "b"
    defp decode_turn("w"), do: :white
    defp decode_turn("b"), do: :black

    defp zero_castling_rights?(b),
        do: b.castling_rights
        |>  Map.values()
        |>  Enum.any?()

    defp encode_castling_rights(b),
        do: (if b.castling_rights.white_rx, do: "K", else: "")
         <> (if b.castling_rights.white_lx, do: "Q", else: "")
         <> (if b.castling_rights.black_rx, do: "k", else: "")
         <> (if b.castling_rights.black_lx, do: "q", else: "")
         <> (if zero_castling_rights?(b),   do: "-", else: "")

    defp decode_castling_rights(c), do: %{
        white_lx: String.contains?(c, "Q"), white_rx: String.contains?(c, "K"),
        black_lx: String.contains?(c, "q"), black_rx: String.contains?(c, "k")
    }

    defp decode_en_passant_target("-"), do: nil
    defp decode_en_passant_target(<<f::binary-size(1), r::binary-size(1)>>),
        do: {String.to_atom(f), String.to_integer(r)}

    defp encode_en_passant_target(%{en_passant_target: nil}), do: "-"
    defp encode_en_passant_target(%{en_passant_target: {file, rank}}), do: "#{file}#{rank}"

    defp find_king_location(squares, color) do
        case Enum.find(squares, fn {_, piece} -> piece == {:king, color} end) do
            {{file, rank}, _} -> {file, rank}
            nil -> nil
        end
    end

    defp decode_squares(text) do
        for {rank_str, rank_idx} <- Enum.with_index(String.split(text, "/")),
            {file_idx, char} <- decode_rank(rank_str),
            into: %{} do
                {{Enum.at(@files, file_idx), 8 - rank_idx}, char_to_piece(char)}
        end
    end

    defp decode_rank(str) do
        str |> String.graphemes()
            |> Enum.reduce({[], 0}, fn char, {pieces, idx} ->
                case Integer.parse(char) do
                    {n, _} -> {pieces, idx + n}
                    _      -> {pieces ++ [{idx, char}], idx + 1}
                end
            end)
            |> elem(0)
    end

    def char_to_piece(char) do
        type = @pieces[String.downcase(char)]
        color = if char =~ ~r/[A-Z]/, do: :white, else: :black
        {type, color}
    end

    defp encode_squares(board) do
        for rank <- 8..1//-1 do
            @files
            |> Enum.map(&Map.get(board.squares, {&1, rank}))
            |> Enum.chunk_by(& &1)
            |> Enum.flat_map(fn
                [nil | _] = nils -> [Integer.to_string(length(nils))]
                pieces           -> Enum.map(pieces, &encode_piece_and_color/1)
            end)
            |> Enum.join("")
        end
        |> Enum.join("/")
    end

    def encode_piece_and_color({piece, color}) do
        letter = @letters[piece]
        if color == :white, do: letter, else: String.downcase(letter)
    end
end
