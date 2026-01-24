defmodule ClusterChess.Sockets.Matchmaking.Test do
    use ExUnit.Case

    alias ClusterChess.Sockets.Matchmaking

    test "Join Matchmaking Queue" do
        msg = %{
            "type" => "queue.join",
            "token" => "Guest",
            "rating" => "1500",
            "preferred_color" => "white",
            "required_color" => "none",
            "ranked" => true,
            "minutes" => "5",
            "increment" => "0"
        }
        result = Matchmaking.handle_in({Jason.encode!(msg), [opcode: :text]}, %{})
        assert {:reply, :ok, {:text, frame}, _state} = result
        IO.inspect(frame)
    end
end
