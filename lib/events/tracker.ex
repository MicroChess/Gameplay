defmodule Tracker do

    use GenServer

    @impl GenServer
    def init(%{raw: state}),
        do: {:ok, state}

    @impl GenServer
    def init(%{game: game}),
        do: {:ok, Persinstence.rehydrate(game)}

    @impl GenServer
    def handle_call(%{type: type, body: body}, sender, state) do
        out = case type do
            "domove"   -> DoMove.update_state(state, body, sender)
            "draw"     -> Draw.update_state(state, body, sender)
            "resign"   -> Resign.update_state(state, body, sender)
            "spectate" -> Spectate.update_state(state, body, sender)
            _unrecognized_msg -> {:error, "unrecognized_msg_type"}
        end
        with {:ok, new_state} <- out do
            Persinstence.sync(new_state)
            Spectate.notify_spectators(new_state)
            {:reply, :ok, new_state}
        else
            :unchanged -> {:reply, :ok, state}
            err -> {:reply, err, state}
        end
    end
end
