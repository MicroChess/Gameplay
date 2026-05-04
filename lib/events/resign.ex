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
        sender = Players.player_color(game.players, req.user)
        { new_history, _fen } = History.register_communication(game.history, "resign", sender)
        case Game.update_state(game, fn game -> update_ending(game, req) end) do
            {:ok, game} -> {:ok, %{ game | history: new_history } }
            {:error, reason} -> {:error, reason}
        end
    end

    def update_ending(game, req) do
        case Players.player_color(game.players, req.user) do
            :white -> {:ok, %{game | ending: %{ winner: :black, reason: :resign }}}
            :black -> {:ok, %{game | ending: %{ winner: :white, reason: :resign }}}
            nil    -> {:error, "invalid resignation"}
        end
    end
end
