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

    def update_state(game, req) do
        case preliminary_checks(game, req) do
            {:error, reason} -> {:error, reason}
            {:ok, :noerrors} -> {:ok, game
                |> apply_move(req)
                |> update_history()
                |> update_pending()
                |> update_timers(req)
                |> update_ending()
            }
        end
    end

    defp preliminary_checks(game, req) do
        both_players = [game.players.white, game.players.black]
        fullmove_count = game.board.counters.fullmoves
        player_color = Players.player_color(game.players, req.user)
        piece_color = Squares.color(game.board.squares, req.from)
        cond do
            game.ending.winner != nil       -> { :error, "game finished" }
            Clock.game_timed_out?(game)     -> { :error, "game timed out" }
            req.user not in both_players    -> { :error, "forbidden: not a player" }
            player_color != game.board.turn -> { :error, "forbidden: not your turn" }
            piece_color != player_color     -> { :error, "forbidden: not your piece" }
            req.count != fullmove_count     -> { :error, "corrupted: wrong move count" }
            true                            -> { :ok, :noerrors }
        end
    end

    defp apply_move(game, req) do
        new_board = Board.apply_move!(game.board, req.from, req.to, req.promotion)
        %{game | board: new_board, pending: @nopending}
    end

    defp update_history(game) do
        new_history = History.register_move(game.history, game.board)
        %{game | history: new_history}
    end

    defp update_pending(game) do
        %{game | pending: @nopending}
    end

    defp update_timers(game, req) do
        player_color = Players.player_color(game.players, req.user)
        %{ game | clock: Clock.update_clock(game, player_color) }
    end

    defp update_ending(game) do
        {color, opponent} = {game.board.turn, Squares.opponent_color(game.board.turn)}
        winning = %{winner: opponent, reason: :timeout}
        losing  = %{winner: color, reason: :checkmate}
        new_ending = cond do
            Clock.player_timed_out?(game, opponent) -> winning
            Squares.king_status(game.board, color) == :checkmate -> losing
            Squares.king_status(game.board, color) == :stalemate -> @stalemate
            true -> @noending
        end
        %{game | ending: new_ending}
    end
end
