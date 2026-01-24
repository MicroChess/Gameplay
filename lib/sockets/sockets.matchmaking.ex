defmodule ClusterChess.Sockets.Matchmaking do

    use ClusterChess.Sockets.Default

    alias ClusterChess.Main.Validation
    alias ClusterChess.Sockets.Commons
    alias ClusterChess.Services.Matchmaking
    alias ClusterChess.Datapacks.Queue

    @message_types ["queue.join", "queue.monitor", "queue.leave"]

    @impl WebSock
    def handle_in({message, [opcode: protocol]}, state) do
        with {:ok, plain} <- Commons.decode(message, protocol),
             {:ok, token} <- Map.fetch(plain, "token"),
             {:ok, mtype} <- Map.fetch(plain, "type"),
             {:ok, _indx} <- Enum.find_index(@message_types, &(&1 == mtype)),
             {:ok, _auth} <- Validation.validate_token(token),
             {:ok, queue} <- Queue.enforce(plain),
             {:ok, mmqid} <- Queue.id(queue),
             {:ok, _resp} <- Commons.delegate(Matchmaking, mmqid, queue)
        do
            Commons.encode!(%{ "msg" => "#{mtype}.ack" }, protocol)
                |> Commons.resp(protocol, state)
        else
            {:error, reason} -> Commons.error(reason, protocol, state)
            _ -> Commons.error("Invalid message format", protocol, state)
        end
    end

    @impl WebSock
    def terminate(_reason, _state) do
        :ok
    end
end
