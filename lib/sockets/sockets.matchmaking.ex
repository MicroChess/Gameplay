defmodule ClusterChess.Sockets.Matchmaking do

    use ClusterChess.Sockets.Default

    alias ClusterChess.Main.Validation
    alias ClusterChess.Sockets.Commons
    alias ClusterChess.Services.Matchmaking
    alias ClusterChess.Datapacks.Queue

    @message_types ["queue.join", "queue.monitor", "queue.stop"]

    @impl WebSock
    def handle_in({message, [opcode: protocol]}, state) do
        with {:ok, plain} <- Commons.decode(message, protocol),
             {:ok, token} <- Map.fetch(plain, "token"),
             {:ok, score} <- Map.fetch(plain, "elo"),
             {:ok, mtype} <- Map.fetch(plain, "type"),
             {:ok, creds} <- Validation.validate_token(token),
             {:ok, queue} <- Queue.enforce(plain),
             {:ok, qguid} <- Queue.id(queue),
             {:ok, _resp} <- Commons.delegate(
                Matchmaking, [qguid], queue
             )
        do
            prev_joined = Map.get(state, :joined_queues, [])
            filterfunc = fn {queue_id, _datapack} -> queue_id != qguid end
            joined_queues = case mtype do
                "queue.stop" -> Enum.filter(prev_joined, filterfunc)
                "queue.join" -> prev_joined ++ [{qguid, queue}]
                _other_types -> prev_joined
            end
            new_state = Map.put(state, :joined_queues, joined_queues)
            Commons.encode!(%{ "msg" => "#{mtype}.ack" }, protocol)
                |> Commons.resp(protocol, new_state)
        else
            {:error, reason} -> Commons.error(reason, protocol, state)
            x -> Commons.error("Invalid message format #{inspect(x)}", protocol, state)
        end
    end

    @impl WebSock
    def terminate(_reason, state) do
        Map.get(state, :joined_queues, []) |> Enum.each(
            fn {qguid, queue} ->
                new = Map.put(queue, :type, "queue.stop")
                Commons.delegate(Matchmaking, qguid, new)
            end
        )
    end
end
