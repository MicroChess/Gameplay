defmodule DoMove do

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
        Game.update_state(state, fn state ->
            both_players = [state.players.white, state.players.black]
            fullmove_count = state.board.counters.fullmoves
            player_color = Game.player_color(state, req.user)
            piece_color = Squares.color(state.board.squares, req.from)
            new_board = Board.apply_move!(state.board, req.from, req.to, req.promotion)
            cond do
                req.user not in both_players -> {:error, "forbidden: not a player"}
                player_color != state.board.turn -> {:error, "forbidden: not your turn"}
                piece_color != player_color -> {:error, "forbidden: not your piece"}
                req.count != fullmove_count  -> {:error, "corrupted: wrong move count"}
                true -> {:ok, %{state | board: new_board, pending: @nopending} }
            end
        end)
    end
end
