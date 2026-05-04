defmodule Undo do
    @nopending    %{ offer_type: nil, requester: nil }

    @derive Jason.Encoder
    defstruct [
        :user,
        :game
    ]

    def update_state(game, req, _sender),
        do: update_state(game, req)

    def update_state(game, req) do
        sender = Players.player_color(game.players, req.user)
        { new_history, fen } = History.register_undo(game.history, sender)
        board = Deserialization.decode_fen(fen)
        case Game.update_state(game, fn game -> update_ending(game, req) end) do
            {:ok, game} -> {:ok, %{ game | history: new_history, board: board } }
            {:error, reason} -> {:error, reason}
        end
    end

    defp update_ending(game, req) do
        both_players = [game.players.white, game.players.black]
        undo_req_ack = %{ game | pending: %{ offer_type: :undo, requester: req.user } }
        undo_accept  = %{ game | pending: @nopending }
        cond do
            req.user not in both_players       -> {:error, "forbidden: not a player"}
            game.ending.winner != nil          -> {:error, "game already over"}
            game.pending.offer_type == nil     -> {:ok, undo_req_ack }
            game.pending.offer_type != :undo   -> {:ok, undo_req_ack }
            game.pending.requester != req.user -> {:ok, undo_accept}
            true                               -> {:error, "invalid undo offer"}
        end
    end
end
