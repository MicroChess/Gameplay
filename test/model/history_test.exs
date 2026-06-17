defmodule History.Test do
    use ExUnit.Case, async: true

    @starting_fen    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    @first_move_fen  "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1"
    @second_move_fen "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 1"
    @third_move_fen  "rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 0 1"

    @empty_board       %Board{}
    @first_move_board  Encoding.decode_fen(@first_move_fen)
    @second_move_board Encoding.decode_fen(@second_move_fen)
    @third_move_board  Encoding.decode_fen(@third_move_fen)

    test "Empty history has correct starting position" do
        new_history = History.new(@empty_board)
        assert History.rollout(new_history) == [
            %{
                type: "starting",
                fen: @starting_fen,
                sender: nil,
                valid: true
            }
        ]
    end

    test "Rollout and roll-in" do
        history = History.new(@empty_board)
            |> History.register_move(@first_move_board)
            |> History.register_move(@second_move_board)
            |> History.register_move(@third_move_board)

        reconstructed_history = History.roll_in(History.rollout(history))
        assert reconstructed_history == history
    end

    test "History is correct after some moves" do
        history = History.new(@empty_board)
            |> History.register_move(@first_move_board)
            |> History.register_move(@second_move_board)
            |> History.register_move(@third_move_board)

        assert History.rollout(history) == [
            %{ type: "move", sender: "white", fen: @third_move_fen,  valid: true },
            %{ type: "move", sender: "black", fen: @second_move_fen, valid: true },
            %{ type: "move", sender: "white", fen: @first_move_fen,  valid: true },
            %{ type: "starting", sender: nil, fen: @starting_fen,    valid: true },
        ]
    end

    test "Latest FEN is actually the latest after some moves" do
        history = History.new(@empty_board)
            |> History.register_move(@first_move_board)
            |> History.register_move(@second_move_board)
            |> History.register_move(@third_move_board)

        assert History.latest_fen(history) == @third_move_fen
    end

    test "Revoke and immediatley check latest FEN" do
        history = History.new(@empty_board)
            |> History.register_move(@first_move_board)
            |> History.register_move(@second_move_board)
            |> History.register_move(@third_move_board)

        revoked_history = History.revoke_latest_move(history)
        assert History.latest_fen(revoked_history) == @second_move_fen
    end
end
