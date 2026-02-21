defmodule KubeChess.Match.Resign do

    alias KubeChess.Match.State

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

    def apply_resign(state, req) do
        case State.player_color(state, req.user) do
            nil -> {:error, "invalid resignation"}
            :white -> {:ok, %{state | ending: %{ winner: :black, reason: :resign }}}
            :black -> {:ok, %{state | ending: %{ winner: :white, reason: :resign }}}
        end
    end
end
