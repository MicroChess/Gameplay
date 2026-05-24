defmodule Persistence.Test do
    use ExUnit.Case

    test "mongodb interaction" do
        case Mongo.insert_one(:mongo_test, "games", %{ "name" => "Test Game" }) do
            {:ok, %{inserted_id: id}} -> {:ok, id}
            {:error, reason} -> {:error, reason}
        end
    end
end
