defmodule Resign do

    @derive Jason.Encoder
    defstruct [
        :user,
        :game,
        :count
    ]

    def update_state(game, req) do
        cond do
            game.ending.winner != nil   -> { :error, "game finished"  }
            Clock.game_timed_out?(game) -> { :error, "game timed out" }
            true ->  {:ok, game
                |> update_history(req)
                |> update_pending()
                |> update_ending(req)
            }
        end
    end

    defp update_history(game, req) do
        sender = Players.player_color(game.players, req.user)
        new_history = History.register_info(game.history, "resign", sender)
        %{ game | history: new_history }
    end

    defp update_pending(game) do
        nopending = %{ offer_type: nil, requester: nil }
        %{game | pending: nopending}
    end

    defp update_ending(game, req) do
        case Players.player_color(game.players, req.user) do
            :white -> {:ok, %{game | ending: %{ winner: :black, reason: :resign }}}
            :black -> {:ok, %{game | ending: %{ winner: :white, reason: :resign }}}
            nil    -> {:error, "invalid resignation"}
        end
    end
end
