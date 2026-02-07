defmodule ClusterChess.Matchmaking.Queue.Test do
    use ExUnit.Case

    alias ClusterChess.Matchmaking.Queue

    test "Parse Queue Datapacks [string keys -> atom keys]" do
        msg = %{
            "type" => "queue.join",
            "token" => "guest",
            "elo" => "1500",
            "gamemode" => "ranked",
            "minutes" => "5",
            "increment" => "0"
        }
        {status, normalized} = Queue.enforce(msg)
        assert :ok == status
        assert :token in Map.keys(normalized)
        assert :type in Map.keys(normalized)
    end

    test "Parse Queue Datapacks [atom keys -> atom keys]" do
        msg = %{
            type: "queue.join",
            token: "guest",
            elo: "1500",
            gamemode: "ranked",
            minutes: "5",
            increment: "0"
        }
        {status, normalized} = Queue.enforce(msg)
        assert :ok == status
        assert :token in Map.keys(normalized)
        assert :type in Map.keys(normalized)
    end
end
