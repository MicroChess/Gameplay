defmodule ClusterChess.Gameplay.Tracker.Test do

    use ExUnit.Case

    alias ClusterChess.Gameplay.Tracker
    alias ClusterChess.Commons.Sentinel
    alias ClusterChess.Gameplay.State

    @example_first_move_req %{
        type: "game.domove",
        from: {:e, 2},
        to: {:e, 4},
        uid: "white_player"
    }

    @example_spectate_req %{
        type: "game.spectate",
        uid: "spectator"
    }

    test "Tracker ok [spectators notified]" do
        {:ok, tracker} = GenServer.start_link(Tracker, %State{})
        {:ok, white_player} = GenServer.start_link(Sentinel, %{})
        {:ok, spectator} = GenServer.start_link(Sentinel, %{})
        Sentinel.impersonate_and_call(spectator, @example_spectate_req, tracker)
        Sentinel.impersonate_and_call(white_player, @example_first_move_req, tracker)
        inbox = Sentinel.impersonate_and_describe(spectator)
        assert length(inbox.messages) == 1
    end
end
