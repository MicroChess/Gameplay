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
        with {:ok, decoded}   <- Formatting.decode(message, protocol),
             {:ok, extended}  <- Map.merge(decoded, state),
             {:ok, msg_type}  <- Map.fetch(extended, "type"),
             {:ok, msg_shape} <- Map.fetch(@shapes, msg_type),
             {:ok, msg_body}  <- Map.fetch(extended, "body"),
             {:ok, datapack}  <- Formatting.enforce(msg_shape, msg_body),
             {:ok, _resp}     <- summon_tracker_and_delegate(state, datapack)
        do
            res = %{ "msg" => "#{msg_type}.ack" }
            res |> Formatting.encode!(protocol)
                |> Formatting.resp(protocol, state)
        else
            {:error, reason} -> Formatting.error(reason, protocol, state)
            msg -> Formatting.error("Invalid msg: #{inspect(msg)}", protocol, state)
        end
    end

    defp summon_tracker_and_delegate(state, datapack) do
        label = %{ game: Map.get(state, :game) }
        settings = {Tracker, :start_link, label}
        outcome = Horde.DynamicSupervisor.start_child(
            :cluster_processes_supervisor,
            %{ id: label, restart: :transient, start: settings}
        )
        pid = case outcome do
            {:ok, pid} -> pid
            {:error, {:already_started, pid}} -> pid
            _ -> summon_tracker_and_delegate(state, datapack)
        end
        GenServer.call(pid, datapack)
    end

    @impl WebSock
    def handle_info({:forward, message}, state),
        do: {:reply, :ok, {:text, message}, state}

    @impl WebSock
    def handle_info(_message, _state),
        do: {:error, "Rejected: Not listening for this message"}
end
