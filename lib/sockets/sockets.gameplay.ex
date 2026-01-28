defmodule ClusterChess.Sockets.Gameplay do

    use ClusterChess.Sockets.Default

    alias ClusterChess.Main.Validation
    alias ClusterChess.Sockets.Commons
    alias ClusterChess.Main.Messaging
    alias ClusterChess.Services.Gameplay

    @shapes %{
        "move.do" => ClusterChess.Datapacks.DoMove,
        "move.undo" => ClusterChess.Datapacks.GameCommunication,
        "game.draw" => ClusterChess.Datapacks.GameCommunication,
        "game.resign" => ClusterChess.Datapacks.GameCommunication,
        "game.spectate" => ClusterChess.Datapacks.GameCommunication
    }

    @impl WebSock
    def handle_in({message, [opcode: protocol]}, state) do
        with {:ok, plain} <- Commons.decode(message, protocol),
             {:ok, token} <- Map.fetch(plain, "token"),
             {:ok, mtype} <- Map.fetch(plain, "type"),
             {:ok, _guid} <- Map.fetch(plain, "game"),
             {:ok, dpack} <- Commons.enforce(@shapes, plain, mtype),
             {:ok, creds} <- Validation.validate_token(token),
             {:ok, _resp} <- delegate_gameplay(dpack, creds)
        do
            Commons.encode!(%{ "msg" => "#{mtype}.ack" }, protocol)
                |> Commons.resp(protocol, state)
        else
            {:error, reason} -> Commons.error(reason, protocol, state)
            msg -> Commons.error("Invalid msg: #{inspect(msg)}", protocol, state)
        end
    end

    defp delegate_gameplay(request, creds) do
        Messaging.search_and_delegate(
            Gameplay,
            Map.merge(request, creds),
            [ game: request.game ]
        )
    end
end
