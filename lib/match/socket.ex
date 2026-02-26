defmodule Match.Socket do

    @behaviour WebSock

    alias Commons.Formatting
    alias Commons.Messaging
    alias Match.Tracker

    @shapes %{
        "game.domove" => Match.DoMove,
        "game.undo" => Match.Communication,
        "game.draw" => Match.Communication,
        "game.resign" => Match.Communication,
        "game.spectate" => Match.Communication
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
        with {:ok, merged} <- state_merge(message, state),
             {:ok, plain}  <- Formatting.decode(merged, protocol),
             {:ok, type}   <- Map.fetch(plain, "type"),
             {:ok, game}   <- Map.fetch(plain, "game"),
             {:ok, dpack}  <- Formatting.enforce(@shapes, plain, type),
             {:ok, _resp}  <- Messaging.search_and_delegate(Tracker, dpack, [ game: game ])
        do
            Formatting.encode!(%{ "msg" => "#{type}.ack" }, protocol)
                |> Formatting.resp(protocol, state)
        else
            {:error, reason} -> Formatting.error(reason, protocol, state)
            msg -> Formatting.error("Invalid msg: #{inspect(msg)}", protocol, state)
        end
    end

    defp state_merge(message, state) do
        {:ok, Map.merge(message, state)}
    end

    @impl WebSock
    def handle_info({:forward, message}, state),
        do: {:reply, :ok, {:text, message}, state}

    @impl WebSock
    def handle_info(_message, _state),
        do: {:error, "Rejected: Not listening for this message"}
end
