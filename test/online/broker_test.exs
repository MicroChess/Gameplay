defmodule Broker.Test do

    use ExUnit.Case

    @valid_event %{
        "type" => "game_creation",
        "body" => %{
            "start_board_fen"  => "r2k3r/8/8/8/8/8/8/R2K3R w KQkq - 0 1",
            "player_max_time"  => 10,
            "time_increment"   => 5,
            "white_player_id"  => "alice",
            "black_player_id"  => "bob"
        }
    }

    @unknown_event %{
        "type" => "unknown_event",
        "body" => %{}
    }

    test "process/1 inserts a new game and returns {:ok, game_id}" do
        assert {:ok, _game_id} = Broker.process(@valid_event)
    end

    test "process/1 returns {:error, :unknown_event_type} for unknown event" do
        assert {:error, :unknown_event_type} = Broker.process(@unknown_event)
    end

    test "process/1 inserts a game that can be rehydrated from MongoDB" do
        {:ok, game_id} = Broker.process(@valid_event)
        source_fen = @valid_event["body"]["start_board_fen"]
        game = Persistence.rehydrate(game_id)
        assert game.players.white == "alice"
        assert game.players.black == "bob"
        assert game.board == Encoding.decode_fen(source_fen)
    end

    test "process/1 correctly sets clock configuration" do
        {:ok, game_id} = Broker.process(@valid_event)
        game = Persistence.rehydrate(game_id)
        assert game.clock.config.initial_time == 10
        assert game.clock.config.increment    == 5
    end

    test "process/1 initialises game with no winner" do
        {:ok, game_id} = Broker.process(@valid_event)
        game = Persistence.rehydrate(game_id)
        assert game.ending.winner == nil
    end
end
