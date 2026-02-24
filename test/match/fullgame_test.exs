defmodule Match.FullGame.Test do

    use ExUnit.Case

    alias Match.DoMove
    alias Match.State
    alias Game.Utilities

    @initial_state State.new(
        60 * 10,          # 10 minutes
        5,                # 5 seconds increment
        "white_player",   # white player user-id
        "black_player"    # black player user-id
    )

    def get_move_request(state, from, to) do
      current_color = state.board.turn
      opponent_color = Utilities.opponent_color(current_color)
      opponent_player = State.player_user_id(state, opponent_color)
      %{
            type: "game.domove",
            from: from,
            to: to,
            user: opponent_player,
            count: 1,
            promotion: nil
        }
    end

    @example_first_move_req %{
        type: "game.domove",
        from: {:e, 2},
        to: {:e, 4},
        user: "white_player",
        count: 1,
        promotion: nil
    }

    @example_second_move_req %{
        type: "game.domove",
        from: {:e, 7},
        to: {:e, 5},
        user: "black_player",
        count: 1,
        promotion: nil
    }

    test "State ok [correctly handles first move]" do
        assert {:ok, _state} = DoMove.update_state(@initial_state, @example_first_move_req)
    end

    test "State ok [correctly handles first two moves]" do
        move1 = @example_first_move_req
        move2 = @example_second_move_req
        assert {:ok, state_after_first_move_1} = DoMove.update_state(@initial_state, move1)
        assert {:ok, _state} = DoMove.update_state(state_after_first_move_1, move2)
    end

    test "State ok [correctly rejects invalid move]" do
        first_move_as_black = @example_second_move_req
        assert {:error, _reason} = DoMove.update_state(@initial_state, first_move_as_black)
    end
end
