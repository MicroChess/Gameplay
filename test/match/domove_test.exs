defmodule Match.DoMove.Test do

    use ExUnit.Case

    alias Match.DoMove
    alias Match.State

    @initial_state State.new(
        60 * 10,          # 10 minutes
        5,                # 5 seconds increment
        "white_player",   # white player user-id
        "black_player"    # black player user-id
    )

    @white_req %DoMove{ type: "game.domove", user: "white_player" }
    @black_req %DoMove{ type: "game.domove", user: "black_player" }

    test "State ok [correctly handles first move]" do
        move = %{ @white_req | from: {:e, 2}, to: {:e, 4}, count: 1}
        assert {:ok, state} = DoMove.update_state(@initial_state, move)
        assert state.board.turn == :black
        assert state.board.counters.halfmoves == 0
        assert state.board.counters.fullmoves == 1
    end

    test "State ok [correctly handles first two moves]" do
        move1 = %{ @white_req | from: {:e, 2}, to: {:e, 4}, count: 1}
        move2 = %{ @black_req | from: {:e, 7}, to: {:e, 5}, count: 1}
        assert {:ok, state} = DoMove.update_state(@initial_state, move1)
        assert {:ok, state} = DoMove.update_state(state, move2)
        assert state.board.turn == :white
        assert state.board.counters.halfmoves == 0
        assert state.board.counters.fullmoves == 2
    end

    test "State ok [correctly handles first three moves]" do
        move1 = %{ @white_req | from: {:e, 2}, to: {:e, 4}, count: 1}
        move2 = %{ @black_req | from: {:e, 7}, to: {:e, 5}, count: 1}
        move3 = %{ @white_req | from: {:g, 1}, to: {:f, 3}, count: 2}
        assert {:ok, state} = DoMove.update_state(@initial_state, move1)
        assert {:ok, state} = DoMove.update_state(state, move2)
        assert {:ok, state} = DoMove.update_state(state, move3)
        assert state.board.turn == :black
        assert state.board.counters.halfmoves == 1
        assert state.board.counters.fullmoves == 2
    end

    test "State ok [correctly rejects invalid black's first move]" do
        move = %{ @black_req | from: {:e, 7}, to: {:e, 5}, count: 1}
        assert {:error, _reason} = DoMove.update_state(@initial_state, move)
    end

    test "State ok [correctly rejects white's ill-counted first move]" do
        move = %{ @white_req | from: {:e, 2}, to: {:e, 4}, count: 3}
        assert {:error, _reason} = DoMove.update_state(@initial_state, move)
    end

    test "State ok [correctly rejects white's attempt to move black pieces]" do
        move = %{ @white_req | from: {:e, 7}, to: {:e, 5}, count: 1}
        assert {:error, _reason} = DoMove.update_state(@initial_state, move)
    end
end
