defmodule Players do

    defstruct [
        white: nil,
        black: nil,
        spectators: MapSet.new(),
    ]

    def new(white, black), do: %__MODULE__{
        white: white,
        black: black,
        spectators: MapSet.new()
    }

    def player_color(players, user) do
        cond do
            players.white == user -> :white
            players.black == user -> :black
            true -> nil
        end
    end

    def player_user_id(players, color) do
        case color do
            :white -> players.white
            :black -> players.black
            _ -> nil
        end
    end
end
