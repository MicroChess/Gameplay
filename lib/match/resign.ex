defmodule Match.Resign do

    alias Match.State

    @derive Jason.Encoder
    defstruct [
        :user,
        :type,
        :game,
        :count
    ]

    def update_state(state, req) do
        State.update_state(state, fn state ->
            case State.player_color(state, req.user) do
                :white -> {:ok, %{state | ending: %{ winner: :black, reason: :resign }}}
                :black -> {:ok, %{state | ending: %{ winner: :white, reason: :resign }}}
                nil    -> {:error, "invalid resignation"}
            end
        end)
    end
end
