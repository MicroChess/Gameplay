defmodule Spectate do

    @derive Jason.Encoder
    defstruct [
        :user,
        :game
    ]

    def update_state(state, {sender_pid, _tag}),
        do: update_state(state, sender_pid)

    def update_state(state, sender_pid) do
        {:ok, update_in(state.players.spectators, fn set ->
            old = set || MapSet.new()
            expansion = MapSet.new([sender_pid])
            MapSet.union(old, expansion)
        end)}
    end

    def notify_spectators(state) do
        spectators = state.players.spectators
        Enum.each(spectators, fn spectator ->
            send(spectator, {:game_update, state})
        end)
    end
end
