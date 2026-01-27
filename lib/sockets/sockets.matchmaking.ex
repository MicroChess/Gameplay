defmodule ClusterChess.Sockets.Matchmaking do

    use ClusterChess.Sockets.Default

    alias ClusterChess.Main.Validation
    alias ClusterChess.Main.Messaging
    alias ClusterChess.Sockets.Commons
    alias ClusterChess.Services.Matchmaking
    alias ClusterChess.Datapacks.Queue

    @message_types ["queue.join", "queue.ping", "queue.leave"]

    @impl WebSock
    def handle_in({message, [opcode: protocol]}, state) do
        with {:ok, plain} <- Commons.decode(message, protocol),
             {:ok, token} <- Map.fetch(plain, "token"),
             {:ok, _rank} <- Map.fetch(plain, "elo"),
             {:ok, mtype} <- Map.fetch(plain, "type"),
             {:ok, _type} <- Commons.contains(@message_types, mtype),
             {:ok, _mode} <- Map.fetch(plain, "gamemode"),
             {:ok, creds} <- Validation.validate_token(token),
             {:ok, queue} <- Queue.enforce(plain),
             {:ok, _resp} <- delegate_matchmaking(queue, creds)
        do
            Commons.encode!(%{ "msg" => "#{mtype}.ack" }, protocol)
                |> Commons.resp(protocol, state)
        else
            {:error, reason} -> Commons.error(reason, protocol, state)
            x -> Commons.error("Invalid message format #{inspect(x)}", protocol, state)
        end
    end

    defp delegate_matchmaking(request, creds) do
        Messaging.summon_and_delegate(
            Matchmaking, request, [
                gamemode: request.gamemode,
                player: creds.uid,
                elo: request.elo
            ]
        )
    end
end
