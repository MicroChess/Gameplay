defmodule Undo do

    @derive Jason.Encoder
    defstruct [
        :user,
        :game
    ]

    def update_state(game, req, _sender),
        do: update_state(game, req)

    def update_state(_state, _req) do

    end
end
