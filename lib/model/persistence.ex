defmodule Persinstence do

    def rehydrate(game_id) do
        selector = %{_id: game_id}
        case Mongo.find_one(:mongo, "games", selector) do
            nil -> {:error, "game not found"}
            obj -> decode_game_bison(obj)
        end
    end

    def sync(game_state) do
        with {:ok, game_id} <- Map.fetch(game_state, :_id),
            do: sync(game_state, game_id),
            else: (_ -> {:error, "cannot sync a non persistent state"})
    end

    def sync(game_state, game_id) do
        obj = encode_game_bison(game_state)
        selector = %{_id: game_id}
        Mongo.replace_one(:mongo, "games", selector, obj)
    end

    defp decode_game_bison(obj) do
        ok_spectators = Map.put(obj.players, :spectators, MapSet.new())
        ok_board = Deserialization.decode_fen(obj.board)
        %{ obj | players: ok_spectators, board: ok_board }
    end

    defp encode_game_bison(game_state) do
        no_spectators = Map.delete(game_state.players, :spectators)
        fen_board = Serialization.encode_fen(game_state.board)
        %{ game_state | players: no_spectators, board: fen_board }
    end
end
