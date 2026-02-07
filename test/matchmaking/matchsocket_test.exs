defmodule ClusterChess.Matchmaking.Socket.Test do
    use ExUnit.Case

    alias ClusterChess.Matchmaking.Socket

    test "Join Matchmaking Queue [success]" do
        msg = %{
            "type" => "queue.join",
            "token" => "Guest",
            "elo" => "1500",
            "gamemode" => "ranked",
            "minutes" => "5",
            "increment" => "0"
        }
        txt = Jason.encode!(msg)
        result = Socket.handle_in({txt, [opcode: :text]}, %{})
        ok_msg = %{"msg" => "queue.join.ack"} |> Jason.encode!()
        assert {:reply, :ok, {:text, ^ok_msg}, _state} = result
    end

    test "Failed Matchmaking Queue [ill-formed json]" do
        msg = %{
            "some" => "invalid data"
        }
        txt = Jason.encode!(msg)
        result = Socket.handle_in({txt, [opcode: :text]}, %{})
        assert {:reply, :ok, {:text, "{\"error\"" <> _rest}, _state} = result
    end

    test "Failed Matchmaking Queue [non-json string]" do
        txt = "some invalid data"
        result = Socket.handle_in({txt, [opcode: :text]}, %{})
        assert {:reply, :ok, {:text, "{\"error\"" <> _rest}, _state} = result
    end
end
