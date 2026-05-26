defmodule Persistence.Test do
    use ExUnit.Case

    test "insert a new game" do
        Persistence.insert(Game.new(
            Clock.new(5, 10),
            Players.new("Alice", "Bob"),
            %Board{}
        ))
    end
end
