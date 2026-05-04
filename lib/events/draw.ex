defmodule Draw do

    @draw         %{ winner: :both,   reason: :draw  }
    @nopending    %{ offer_type: nil, requester: nil }

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
        { new_history, _fen } = History.register_communication(game.history, "draw", sender)
        case Game.update_state(game, fn game -> update_ending(game, req) end) do
            {:ok, game} -> {:ok, %{ game | history: new_history } }
            {:error, reason} -> {:error, reason}
        end
    end

    defp update_ending(game, req) do
        both_players = [game.players.white, game.players.black]
        draw_req_ack = %{ game | pending: %{ offer_type: :draw, requester: req.user } }
        draw_accept  = %{ game | pending: @nopending, ending: @draw }
        cond do
            req.user not in both_players       -> {:error, "forbidden: not a player"}
            game.ending.winner != nil          -> {:error, "game already over"}
            game.pending.offer_type == nil     -> {:ok, draw_req_ack }
            game.pending.offer_type != :draw   -> {:ok, draw_req_ack }
            game.pending.requester != req.user -> {:ok, draw_accept}
            true -> {:error, "invalid draw offer"}
        end
    end
end
