defmodule Persistence.Test do
    use ExUnit.Case

    @alice_vs_bob_game Game.new(
        Clock.new(5, 10),
        Players.new("Alice", "Bob"),
        %Board{}
    )

    @alice_first_move %DoMove{
        user: "Alice",
        count: 1,
        from: {:e, 2},
        to: {:e, 4},
        promotion: nil
    }

    test "insert a new game" do
        Persistence.insert(@alice_vs_bob_game)
    end

    test "insert a new game and retrieve it" do
        {:ok, game_id} = Persistence.insert(@alice_vs_bob_game)
        retrieved_game = Persistence.rehydrate(game_id)
        assert retrieved_game == @alice_vs_bob_game
    end

    test "insert a new game, retrieve it, sync it and retrieve it again (no history)" do
        {:ok, game_id} = Persistence.insert(@alice_vs_bob_game)
        retrieved_game = Persistence.rehydrate(game_id)
        {:ok, updated_game} = DoMove.update_state(retrieved_game, @alice_first_move)
        Persistence.sync(updated_game, game_id)
        retrieved_updated_game = Persistence.rehydrate(game_id)
        assert Map.delete(retrieved_updated_game, :history) == Map.delete(updated_game, :history)
    end

    test "insert a new game, retrieve it, sync it and retrieve it again (only history)" do
        {:ok, game_id} = Persistence.insert(@alice_vs_bob_game)
        retrieved_game = Persistence.rehydrate(game_id)
        {:ok, updated_game} = DoMove.update_state(retrieved_game, @alice_first_move)
        Persistence.sync(updated_game, game_id)
        retrieved_updated_game = Persistence.rehydrate(game_id)
        assert retrieved_updated_game.history == updated_game.history
    end
end
