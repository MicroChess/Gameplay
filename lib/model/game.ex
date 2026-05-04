defmodule Game do

    alias Squares
    alias Board
    alias Clock
    alias Utilities

    @stalemate    %{ winner: :both,   reason: :stalemate }
    @noending     %{ winner: nil,     reason: nil        }

    defstruct [
        board:   %Board{},
        clock:   %Clock{},
        players: %Players{},
        ending:  %{ winner: nil, reason: nil },
        pending: %{ offer_type: nil, requester: nil },
        history: %History{},
    ]

    def new(clock, players, board),
        do: %__MODULE__{
            board: board,
            clock: clock,
            history: History.new(board),
            players: players
        }

    def update_state(state, callback) do
        updated = cond do
            state.ending.winner != nil    -> {:error, "game finished"}
            Clock.game_timed_out?(state)  -> {:error, "game timed out"}
            true                          -> callback.(state)
        end
        case updated do
            {:ok, new_state} -> {:ok, %{ new_state | ending: update_ending(new_state) }}
            other -> other
        end
    end

    def update_ending(state) do
        {color, opponent} = { state.board.turn, Squares.opponent_color(state.board.turn) }
        checkmate_ending = %{ state.ending | winner: color, reason: :checkmate }
        timeout_ending = %{ state.ending | winner: opponent, reason: :timeout }
        king_status = Utilities.king_status(state.board, color)
        cond do
            Clock.player_timed_out?(state, color) -> timeout_ending
            king_status == :checkmate -> checkmate_ending
            king_status == :stalemate -> @stalemate
            true -> @noending
        end
    end
end
