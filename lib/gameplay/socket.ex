defmodule KubeChess.Gameplay.Socket do

    use KubeChess.Commons.Socket

    alias KubeChess.Commons.Validation
    alias KubeChess.Commons.Formatting
    alias KubeChess.Main.Messaging
    alias KubeChess.Gameplay.Tracker

    @shapes %{
        "game.domove" => KubeChess.Gameplay.DoMove,
        "game.undo" => KubeChess.Gameplay.Communication,
        "game.draw" => KubeChess.Gameplay.Communication,
        "game.resign" => KubeChess.Gameplay.Communication,
        "game.spectate" => KubeChess.Gameplay.Communication
    }

    @impl WebSock
    def handle_in({message, [opcode: protocol]}, state) do
        with {:ok, plain} <- Formatting.decode(message, protocol),
             {:ok, token} <- Map.fetch(plain, "token"),
             {:ok, mtype} <- Map.fetch(plain, "type"),
             {:ok, _guid} <- Map.fetch(plain, "game"),
             {:ok, dpack} <- Formatting.enforce(@shapes, plain, mtype),
             {:ok, creds} <- Validation.validate_token(token),
             {:ok, _resp} <- delegate_gameplay(dpack, creds)
        do
            Formatting.encode!(%{ "msg" => "#{mtype}.ack" }, protocol)
                |> Formatting.resp(protocol, state)
        else
            {:error, reason} -> Formatting.error(reason, protocol, state)
            msg -> Formatting.error("Invalid msg: #{inspect(msg)}", protocol, state)
        end
    end

    defp delegate_gameplay(request, creds) do
        Messaging.search_and_delegate(
            Tracker,
            Map.merge(request, creds),
            [ game: request.game ]
        )
    end
end
