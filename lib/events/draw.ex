defmodule Draw do

    @nopending    %{ offer_type: nil, requester: nil }
    @draw_ending  %{ winner: :both,   reason: :draw  }

    @derive Jason.Encoder
    defstruct [
        :user,
        :game,
        :count
    ]

    def update_state(game, req) do
        both_players = [game.players.white, game.players.black]
        cond do
            game.ending.winner != nil          -> {:error, "game finished" }
            Clock.game_timed_out?(game)        -> {:error, "game timed out" }
            req.user not in both_players       -> {:error, "forbidden: not a player" }
            game.ending.winner != nil          -> {:error, "game already over" }
            game.pending.offer_type == nil     -> {:ok, draw_req_ack(game, req) }
            game.pending.offer_type != :draw   -> {:ok, draw_req_ack(game, req) }
            game.pending.requester != req.user -> {:ok, perform_draw(game, req)  }
            true                               -> {:error, "invalid draw offer" }
        end
    end

    def perform_draw(game, req) do
        { new_history, _fen } = History.register_communication(
            game.history, "draw-acceptance", req.user
        )
        %{ game | history: new_history, pending: @nopending, ending: @draw_ending }
    end

    def draw_req_ack(game, req) do
        draw_req_ack = %{ offer_type: :draw, requester: req.user }
        { new_history, _fen } = History.register_communication(
            game.history, "draw-proposal", req.user
        )
        %{ game | pending: draw_req_ack, history: new_history }
    end
end
