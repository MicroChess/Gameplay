defmodule Persistence do

    @mongodb_instance Application.compile_env(:microchess_gameplay, :mongo_conn, :mongo)

    def rehydrate(game_id) do
        selector = %{_id: game_id}
        case Mongo.find_one(@mongodb_instance, "games", selector) do
            nil -> {:error, "game not found"}
            obj -> Deserialization.decode_game_bison(obj)
        end
    end

    def insert(game_state) do
        obj = Serialization.encode_game_bison(game_state)
        case Mongo.insert_one(@mongodb_instance, "games", obj) do
            {:ok, %{inserted_id: id}} -> {:ok, id}
            {:error, reason} -> {:error, reason}
        end
    end

    def sync(game_state) do
        with {:ok, game_id} <- Map.fetch(game_state, :_id),
            do: sync(game_state, game_id),
            else: (_ -> {:error, "cannot sync a non persistent state"})
    end

    def sync(game_state, game_id) do
        obj = Serialization.encode_game_bison(game_state)
        selector = %{_id: game_id}
        Mongo.replace_one(@mongodb_instance, "games", selector, obj)
    end
end
