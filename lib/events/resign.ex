defmodule Resign do

    @derive Jason.Encoder
    defstruct [
        :user,
        :type,
        :game,
        :count
    ]

    def update_state(state, req) do
        Game.update_state(state, fn state ->
            case Game.player_color(state, req.user) do
                :white -> {:ok, %{state | ending: %{ winner: :black, reason: :resign }}}
                :black -> {:ok, %{state | ending: %{ winner: :white, reason: :resign }}}
                nil    -> {:error, "invalid resignation"}
            end
        end)
    end
end
