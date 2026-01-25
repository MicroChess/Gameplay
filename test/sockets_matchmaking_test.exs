defmodule ClusterChess.Sockets.Matchmaking.Test do
    use ExUnit.Case

    alias ClusterChess.Sockets.Matchmaking

    test "Join Matchmaking Queue [success]" do
        msg = %{
            "type" => "queue.join",
            "token" => "Guest",
            "pool" => "ranked",
            "minutes" => "5",
            "increment" => "0"
        }
        txt = Jason.encode!(msg)
        result = Matchmaking.handle_in({txt, [opcode: :text]}, %{})
        assert {:reply, :ok, {:text, _reply}, _state} = result
    end

    test "Failed Matchmaking Queue [ill-formed json]" do
        msg = %{
            "some" => "invalid data"
        }
        txt = Jason.encode!(msg)
        result = Matchmaking.handle_in({txt, [opcode: :text]}, %{})
        assert {:reply, :ok, {:text, _reply}, _state} = result
    end

    test "Failed Matchmaking Queue [non-json string]" do
        txt = "some invalid data"
        result = Matchmaking.handle_in({txt, [opcode: :text]}, %{})
        assert {:reply, :ok, {:text, _reply}, _state} = result
    end
end
