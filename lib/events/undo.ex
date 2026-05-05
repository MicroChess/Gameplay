defmodule Undo do
    @nopending    %{ offer_type: nil, requester: nil }

    @derive Jason.Encoder
    defstruct [
        :user,
        :game
    ]

    def update_state(game, req) do
        both_players = [game.players.white, game.players.black]
        cond do
            game.ending.winner != nil          -> {:error, "game finished" }
            Clock.game_timed_out?(game)        -> {:error, "game timed out" }
            req.user not in both_players       -> {:error, "forbidden: not a player" }
            game.ending.winner != nil          -> {:error, "game already over" }
            game.pending.offer_type == nil     -> {:ok, undo_req_ack(game, req) }
            game.pending.offer_type != :undo   -> {:ok, undo_req_ack(game, req) }
            game.pending.requester != req.user -> {:ok, perform_undo(game, req)  }
            true                               -> {:error, "invalid undo offer" }
        end
    end

    def perform_undo(game, req) do
        sender = Players.player_color(game.players, req.user)
        { new_history, fen } = History.register_undo(game.history, sender)
        board = Deserialization.decode_fen(fen)
        %{ game | history: new_history, board: board, pending: @nopending }
    end

    def undo_req_ack(game, req) do
        undo_req_ack = %{ offer_type: :undo, requester: req.user }
        { new_history, _fen } = History.register_communication(
            game.history, "undo-proposal", req.user
        )
        %{ game | pending: undo_req_ack, history: new_history }
    end
end
