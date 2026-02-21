defmodule KubeChess.Gameplay.State.Test do

    use ExUnit.Case

    alias KubeChess.Gameplay.State

    @initial_state State.new(
        60 * 10,          # 10 minutes
        5,                # 5 seconds increment
        "white_player",   # white player uid
        "black_player"    # black player uid
    )

    @example_first_move_req %{
        type: "game.domove",
        from: {:e, 2},
        to: {:e, 4},
        uid: "white_player"
    }

    @example_second_move_req %{
        type: "game.domove",
        from: {:e, 7},
        to: {:e, 5},
        uid: "black_player"
    }

    test "State ok [correctly handles first move]" do
        assert {:ok, _state} = State.apply_move(@initial_state, @example_first_move_req)
    end

    test "State ok [correctly handles first two moves]" do
        move1 = @example_first_move_req
        move2 = @example_second_move_req
        assert {:ok, state_after_first_move_1} = State.apply_move(@initial_state, move1)
        assert {:ok, _state} = State.apply_move(state_after_first_move_1, move2)
    end

    test "State ok [correctly rejects invalid move]" do
        first_move_as_black = @example_second_move_req
        assert {:error, _reason} = State.apply_move(@initial_state, first_move_as_black)
    end
end
