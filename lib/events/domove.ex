defmodule DoMove do

    @nopending %{ offer_type: nil, requester: nil     }
    @stalemate %{ winner: :both,   reason: :stalemate }
    @noending  %{ winner: nil,     reason: nil        }

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
            player_color = Players.player_color(game.players, req.user)
            piece_color = Squares.color(game.board.squares, req.from)
            cond do
                req.user not in both_players    -> { :error, "forbidden: not a player" }
                player_color != game.board.turn -> { :error, "forbidden: not your turn" }
                piece_color != player_color     -> { :error, "forbidden: not your piece" }
                req.count != fullmove_count     -> { :error, "corrupted: wrong move count" }
                true                            -> { :ok, update_ending(game, req) }
            end
        end)
    end

    defp update_ending(game, req) do
        new_board = Board.apply_move!(game.board, req.from, req.to, req.promotion)
        { new_history, _fen } = History.register_move(game.history, game.board)
        patch = %{ board: new_board, pending: @nopending, history: new_history }
        Map.merge(game, patch)
    end
end
