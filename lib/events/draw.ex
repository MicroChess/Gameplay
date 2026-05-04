defmodule Draw do

    @stalemate    %{ winner: :both,   reason: :stalemate }
    @nopending    %{ offer_type: nil, requester: nil     }

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
            both_players = [game.players.white, game.players.black]
            draw_req_ack = %{ game | pending: %{ offer_type: :draw, requester: req.user } }
            draw_accept  = %{ game | pending: @nopending, ending: @stalemate }
            cond do
                req.user not in both_players       -> {:error, "forbidden: not a player"}
                game.ending.winner != nil          -> {:error, "game already over"}
                game.pending.offer_type == nil     -> {:ok, draw_req_ack }
                game.pending.offer_type != :draw   -> {:ok, draw_req_ack }
                game.pending.requester != req.user -> {:ok, draw_accept}
                true -> {:error, "invalid draw offer"}
            end
        end)
    end
end
