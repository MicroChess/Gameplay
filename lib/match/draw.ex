defmodule Match.Draw do

    alias Match.State

    @stalemate    %{ winner: :both,   reason: :stalemate }
    @nopending    %{ offer_type: nil, requester: nil     }

    @derive Jason.Encoder
    defstruct [
        :user,
        :type,
        :game,
        :count
    ]

    def update_state(state, req) do
        State.update_state(state, fn state ->
            white_player = state.players.white
            black_player = state.players.black
            draw_req_ack = %{ state | pending: %{ offer_type: :draw, requester: req.user } }
            draw_accept = %{ state | pending: @nopending, ending: @stalemate }
            cond do
                req.user not in [white_player, black_player] -> {:error, "forbidden: not a player"}
                state.ending.winner != nil -> {:error, "game already over"}
                state.pending.offer_type == nil -> {:ok, draw_req_ack }
                state.pending.offer_type != :draw -> {:ok, draw_req_ack }
                state.pending.requester != req.user -> {:ok, draw_accept}
                true -> {:error, "invalid draw offer"}
            end
        end)
    end
end
