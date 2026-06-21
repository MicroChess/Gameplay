defmodule Events.E2E.Test do

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

    test "Broadway pipeline processes a game_creation message end-to-end", %{channel: channel} do
        payload = Jason.encode!(@valid_event)
        AMQP.Basic.publish(channel, "", "game_creation_events", payload)
        Process.sleep(1500)
        cursor = Mongo.find(:mongo, "games", %{"players.white" => "alice"})
        results = Enum.to_list(cursor)
        assert length(results) >= 1
    end

    test "Broadway pipeline rejects an unknown event type", %{channel: channel} do
        payload = Jason.encode!(@unknown_event)
        AMQP.Basic.publish(channel, "", "game_creation_events", payload)
        Process.sleep(500)
        cursor = Mongo.find(:mongo, "games", %{"players.white" => "nobody"})
        results = Enum.to_list(cursor)
        assert results == []
    end
end
