defmodule KubeChess.Match.Draw do

    @stalemate    %{ winner: :both,   reason: :stalemate }
    @nopending    %{ offer_type: nil, requester: nil     }

    @derive Jason.Encoder
    defstruct [
        :type,
        :token,
        :game,
        :count,
        :from,
        :to,
        :promotion
    ]

    def apply_draw(state, req) do
        white_player = state.players.white
        black_player = state.players.black
        draw_req_ack = %{ state | pending: %{ offer_type: :draw, requester: req.uid } }
        draw_accept = %{ state | pending: @nopending, ending: @stalemate }
        cond do
            req.uid not in [white_player, black_player] -> {:error, "forbidden: not a player"}
            state.ending.winner != nil -> {:error, "game already over"}
            state.pending.offer_type == nil -> {:ok, draw_req_ack }
            state.pending.offer_type != :draw -> {:ok, draw_req_ack }
            state.pending.requester != req.uid -> {:ok, draw_accept}
            true -> {:error, "invalid draw offer"}
        end
    end
end
