defmodule Socket do

    @behaviour WebSock

    @shapes %{
        "domove"   => DoMove,
        "undo"     => Undo,
        "draw"     => Draw,
        "resign"   => Resign,
        "spectate" => Spectate,
    }

    @impl WebSock
    def init(state) do
        case state do
            %{user: _user_id, game: _game_id} -> {:ok, state}
            _ -> {:error, "Invalid initial state"}
        end
    end

    @impl WebSock
    def handle_in({_msg, [opcode: protocol]}, state)
        when (protocol not in [:text, :binary]), do: {:ok, state}

    @impl WebSock
    def handle_in({message, [opcode: protocol]}, state) do
        label = %{ game: Map.get(state, :game) }
        with {:ok, decoded}    <- Formatting.decode(message, protocol),
             {:ok, datapack}   <- Map.merge(decoded, state),
             {:ok, dpack_type} <- Map.fetch(datapack, "type"),
             {:ok, enforced}   <- Formatting.enforce(@shapes, datapack, dpack_type),
             {:ok, _resp}      <- Messaging.summon_and_delegate(Tracker, enforced, label)
        do
            res = %{ "msg" => "#{dpack_type}.ack" }
            res |> Formatting.encode!(protocol)
                |> Formatting.resp(protocol, state)
        else
            {:error, reason} -> Formatting.error(reason, protocol, state)
            msg -> Formatting.error("Invalid msg: #{inspect(msg)}", protocol, state)
        end
    end

    @impl WebSock
    def handle_info({:forward, message}, state),
        do: {:reply, :ok, {:text, message}, state}

    @impl WebSock
    def handle_info(_message, _state),
        do: {:error, "Rejected: Not listening for this message"}
end
