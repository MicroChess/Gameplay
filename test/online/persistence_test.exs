defmodule Persistence.Test do
    use ExUnit.Case

    @alice_vs_bob_game Game.new(
        Clock.new(5, 10),
        Players.new("Alice", "Bob"),
        %Board{}
    )

    test "insert a new game" do
        Persistence.insert(@alice_vs_bob_game)
    end

    test "insert a new game and retrieve it" do
        {:ok, retrieve_id} = Persistence.insert(@alice_vs_bob_game)
        retrieved_game = Persistence.rehydrate(retrieve_id)
        assert retrieved_game == @alice_vs_bob_game
    end
end
