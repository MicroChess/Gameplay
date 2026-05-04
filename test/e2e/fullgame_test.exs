defmodule FullTest do

    use ExUnit.Case

    @initial_state Game.new(
        Clock.new(60 * 10, 5),
        Players.new("white_player", "black_player"),
        %Board{}
    )

    def get_move_request(state, from, to) do
      current_color = state.board.turn
      opponent_color = Squares.opponent_color(current_color)
      opponent_player = Players.player_user_id(state.players, opponent_color)
      %{
            type: "domove",
            from: from,
            to: to,
            user: opponent_player,
            count: 1,
            promotion: nil
        }
    end

    @example_first_move_req %{
        type: "domove",
        from: {:e, 2},
        to: {:e, 4},
        user: "white_player",
        count: 1,
        promotion: nil
    }

    @example_second_move_req %{
        type: "domove",
        from: {:e, 7},
        to: {:e, 5},
        user: "black_player",
        count: 1,
        promotion: nil
    }

    test "Game ok [correctly handles first move]" do
        assert {:ok, _state} = DoMove.update_state(@initial_state, @example_first_move_req)
    end

    test "Game ok [correctly handles first two moves]" do
        move1 = @example_first_move_req
        move2 = @example_second_move_req
        assert {:ok, state_after_first_move_1} = DoMove.update_state(@initial_state, move1)
        assert {:ok, _state} = DoMove.update_state(state_after_first_move_1, move2)
    end

    test "Game ok [correctly rejects invalid move]" do
        first_move_as_black = @example_second_move_req
        assert {:error, _reason} = DoMove.update_state(@initial_state, first_move_as_black)
    end
end
