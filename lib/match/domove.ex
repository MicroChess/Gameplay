defmodule Match.DoMove do

    alias Game.MakeMoves
    alias Match.State

    @nopending %{ offer_type: nil, requester: nil }

    @derive Jason.Encoder
    defstruct [
        :user,
        :type,
        :game,
        :count,
        :from,
        :to,
        :promotion
    ]

    def update_state(state, req) do
        State.update_state(state, fn state -> state
            |> preliminary_check(req)
            |> apply_move(req)
            |> apply_promotion(req)
        end)
    end

    defp preliminary_check(state, req) do
        both_players = [state.players.white, state.players.black]
        fullmove_count = state.board.counters.fullmove
        cond do
            req.user not in both_players -> {:error, "forbidden: not a player"}
            req.user != state.board.turn -> {:error, "forbidden: not your turn"}
            req.count != fullmove_count  -> {:error, "corrupted: wrong move count"}
            true -> {:ok, state}
        end
    end

    defp apply_move({:error, _reason} = error, _req), do: error
    defp apply_move({:ok, state}, req) do
        out = MakeMoves.apply_move(state.board, req.from, req.to)
        if out == :invalid_move,
            do: {:error, "invalid_move"},
            else: {:ok, %{state | board: out, pending: @nopending}}
    end

    defp apply_promotion({:error, _reason} = error, _req), do: error
    defp apply_promotion({:ok, state}, _req), do: {:ok, state}
end
