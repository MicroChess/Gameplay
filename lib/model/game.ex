defmodule Game do

    defstruct [
        board:   %Board{},
        clock:   %Clock{},
        players: %Players{},
        history: %History{},
        ending:  %{
            winner: nil,
            reason: nil
        },
        pending: %{
            offer_type: nil,
            requester: nil
        },
    ]

    def new(clock, players, board), do: %__MODULE__{
        board: board,
        clock: clock,
        history: History.new(board),
        players: players
    }
end
