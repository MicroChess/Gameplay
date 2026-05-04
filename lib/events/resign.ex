defmodule Resign do

    @derive Jason.Encoder
    defstruct [
        :user,
        :game,
        :count
    ]

    def update_state(game, req, _sender),
        do: update_state(game, req)

    def update_state(game, req) do
        Game.update_state(game, fn game ->
            case Players.player_color(game.players, req.user) do
                :white -> {:ok, %{game | ending: %{ winner: :black, reason: :resign }}}
                :black -> {:ok, %{game | ending: %{ winner: :white, reason: :resign }}}
                nil    -> {:error, "invalid resignation"}
            end
        end)
    end
end
