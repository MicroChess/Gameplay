defmodule KubeChess.Match.DoMove do

    alias KubeChess.Game.MakeMoves
    alias KubeChess.Match.State

    @nopending %{ offer_type: nil, requester: nil }

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

    def apply_move(state, req), do: State.update_state(state, fn state ->
        {from, to} = {req.from, req.to}
        out = MakeMoves.apply_move(state.board, from, to)
        if out == :invalid_move,
            do: {:error, "invalid_move"},
            else: {:ok, %{state | board: out, pending: @nopending}}
    end)
end
