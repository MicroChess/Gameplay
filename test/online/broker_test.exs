defmodule Broker.Test do

    use ExUnit.Case

    @starting_fen "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

    @valid_event %{
        "type" => "game_creation",
        "body" => %{
            "start_board_fen"  => @starting_fen,
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

    @valid_payload Jason.encode!(
        @valid_event
    )

    setup_all do
        host = System.get_env("RABBITMQ_HOST", "localhost")
        port = String.to_integer(System.get_env("RABBITMQ_PORT", "5672"))
        user = System.get_env("RABBITMQ_USER", "guest")
        pass = System.get_env("RABBITMQ_PASS", "guest")

        {:ok, amqp_conn} = AMQP.Connection.open(host: host, port: port, username: user, password: pass)
        {:ok, channel}   = AMQP.Channel.open(amqp_conn)
        AMQP.Queue.declare(channel, "game_creation_events", durable: true)

        on_exit(fn -> AMQP.Connection.close(amqp_conn) end)

        {:ok, channel: channel}
    end

    test "process/1 inserts a new game and returns {:ok, game_id}" do
        assert {:ok, _game_id} = Broker.process(@valid_event)
    end

    test "process/1 returns {:error, :unknown_event_type} for unknown event" do
        assert {:error, :unknown_event_type} = Broker.process(@unknown_event)
    end

    test "process/1 inserts a game that can be rehydrated from MongoDB" do
        {:ok, game_id} = Broker.process(@valid_event)
        game = Persistence.rehydrate(game_id)
        assert game.players.white == "alice"
        assert game.players.black == "bob"
        assert game.board == Encoding.decode_fen(@starting_fen)
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

    test "Broadway pipeline processes a game_creation message end-to-end", %{channel: channel} do
        AMQP.Basic.publish(channel, "", "game_creation_events", @valid_payload)
        Process.sleep(1500)
        cursor = Mongo.find(:mongo, "games", %{"players.white" => "alice"})
        results = Enum.to_list(cursor)
        assert length(results) >= 1
    end

    test "Broadway pipeline rejects an unknown event type", %{channel: channel} do
        payload = Jason.encode!(%{"type" => "unknown", "body" => %{}})
        AMQP.Basic.publish(channel, "", "game_creation_events", payload)
        Process.sleep(500)
        cursor = Mongo.find(:mongo, "games", %{"players.white" => "nobody"})
        results = Enum.to_list(cursor)
        assert results == []
    end
end
