defmodule DoMove do

    @nopending %{ offer_type: nil, requester: nil }

    @derive Jason.Encoder
    defstruct [
        :user,
        :game,
        :count,
        :from,
        :to,
        :promotion
    ]

    def update_state(game, req, _sender),
        do: update_state(game, req)

    def update_state(game, req) do
        Game.update_state(game, fn game ->
            both_players = [game.players.white, game.players.black]
            fullmove_count = game.board.counters.fullmoves
            player_color = Game.player_color(game, req.user)
            piece_color = Squares.color(game.board.squares, req.from)
            new_board = Board.apply_move!(game.board, req.from, req.to, req.promotion)
            cond do
                req.user not in both_players    -> {:error, "forbidden: not a player"}
                player_color != game.board.turn -> {:error, "forbidden: not your turn"}
                piece_color != player_color     -> {:error, "forbidden: not your piece"}
                req.count != fullmove_count     -> {:error, "corrupted: wrong move count"}
                true -> {:ok, %{game | board: new_board, pending: @nopending} }
            end
        end)
    end
end
