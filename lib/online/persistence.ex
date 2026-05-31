defmodule Persistence do

    @mongodb_instance Application.compile_env(:microchess_gameplay, :mongo_conn, :mongo)

    def encode_game_bison(game_state), do: %{
        board:   Encoding.encode_fen(game_state.board),
        players: Map.from_struct(game_state.players),
        clock:   Map.from_struct(game_state.clock),
        history: Map.from_struct(game_state.history),
        ending:  game_state.ending,
        pending: game_state.pending,
    }

    def decode_game_bison(obj), do: %Game{
        board:   Encoding.decode_fen(obj["board"]),
        clock:   struct(Clock, Morphix.atomorphiform!(obj["clock"])),
        history: struct(History, Morphix.atomorphiform!(obj["history"])),
        ending:  Morphix.atomorphiform!(obj["ending"]),
        pending: Morphix.atomorphiform!(obj["pending"]),
        players: Players.new(
            obj["players"]["white"],
            obj["players"]["black"]
        ),
    }

    def rehydrate(game_id) do
        selector = %{_id: game_id}
        case Mongo.find_one(@mongodb_instance, "games", selector) do
            nil -> {:error, "game not found"}
            obj -> decode_game_bison(obj)
        end
    end

    def insert(game_state) do
        obj = encode_game_bison(game_state)
        case Mongo.insert_one(@mongodb_instance, "games", obj) do
            {:ok, %{inserted_id: id}} -> {:ok, id}
            {:error, reason} -> {:error, reason}
        end
    end

    def sync(game_state, game_id) do
        obj = encode_game_bison(game_state)
        selector = %{_id: game_id}
        Mongo.replace_one(@mongodb_instance, "games", selector, obj)
    end
end
