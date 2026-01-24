defmodule ClusterChess.Datapacks.Queue.Test do
    use ExUnit.Case

    alias ClusterChess.Datapacks.Queue

    test "Parse Queue Datapacks [string keys -> atom keys]" do
        msg = %{
            "token" => "guest",
            "rating" => "1500",
            "preferred_color" => "white",
            "required_color" => "none",
            "ranked" => true,
            "minutes" => "5",
            "increment" => "0"
        }
        {status, normalized} = Queue.enforce(msg)
        assert :ok == status
        assert :token in Map.keys(normalized)
    end

    test "Parse Queue Datapacks [atom keys -> atom keys]" do
        msg = %{
            token: "guest",
            rating: "1500",
            preferred_color: "white",
            required_color: "none",
            ranked: true,
            minutes: "5",
            increment: "0"
        }
        {status, normalized} = Queue.enforce(msg)
        assert :ok == status
        assert :token in Map.keys(normalized)
    end
end
