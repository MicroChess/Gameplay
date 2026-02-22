defmodule Match.Tracker.Test do

    use ExUnit.Case

    alias Match.Tracker
    alias Commons.Sentinel
    alias Match.State

    @messages_used_for_subscription 1

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

    @example_spectate_req %{
        type: "game.spectate",
        uid: "spectator"
    }

    test "Tracker ok [spectators notified]" do
        {:ok, tracker} = GenServer.start_link(Tracker, @initial_state)
        {:ok, white_player} = GenServer.start_link(Sentinel, %{})
        {:ok, spectator} = GenServer.start_link(Sentinel, %{})
        Sentinel.impersonate_and_call(spectator, @example_spectate_req, tracker)
        Sentinel.impersonate_and_call(white_player, @example_first_move_req, tracker)
        inbox = Sentinel.impersonate_and_describe(spectator)
        assert length(inbox.messages) == @messages_used_for_subscription + 1
    end

    test "Tracker ok [spectators notified more then once]" do
        {:ok, tracker} = GenServer.start_link(Tracker, @initial_state)
        {:ok, white_player} = GenServer.start_link(Sentinel, %{})
        {:ok, black_player} = GenServer.start_link(Sentinel, %{})
        {:ok, spectator} = GenServer.start_link(Sentinel, %{})
        Sentinel.impersonate_and_call(spectator, @example_spectate_req, tracker)
        Sentinel.impersonate_and_call(white_player, @example_first_move_req, tracker)
        Sentinel.impersonate_and_call(black_player, @example_second_move_req, tracker)
        inbox = Sentinel.impersonate_and_describe(spectator)
        assert length(inbox.messages) == @messages_used_for_subscription + 2
    end

    test "Tracker ok [spectators not notified on errors]" do
        {:ok, tracker} = GenServer.start_link(Tracker, @initial_state)
        {:ok, black_player} = GenServer.start_link(Sentinel, %{})
        {:ok, spectator} = GenServer.start_link(Sentinel, %{})
        Sentinel.impersonate_and_call(spectator, @example_spectate_req, tracker)
        Sentinel.impersonate_and_call(black_player, @example_second_move_req, tracker)
        inbox = Sentinel.impersonate_and_describe(spectator)
        assert length(inbox.messages) == @messages_used_for_subscription + 0
    end
end
