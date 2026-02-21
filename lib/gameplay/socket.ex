defmodule KubeChess.Gameplay.Socket do

    use KubeChess.Commons.Socket

    alias KubeChess.Commons.Formatting
    alias KubeChess.Commons.Messaging
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
             {:ok, type}  <- Map.fetch(plain, "type"),
             {:ok, game}  <- Map.fetch(plain, "game"),
             {:ok, dpack} <- Formatting.enforce(@shapes, plain, type),
             {:ok, _resp} <- Messaging.search_and_delegate(Tracker, dpack, [ game: game ])
        do
            Formatting.encode!(%{ "msg" => "#{type}.ack" }, protocol)
                |> Formatting.resp(protocol, state)
        else
            {:error, reason} -> Formatting.error(reason, protocol, state)
            msg -> Formatting.error("Invalid msg: #{inspect(msg)}", protocol, state)
        end
    end
end
