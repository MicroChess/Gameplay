defmodule KubeChess.Match.State do

    alias Bandit.Clock
    alias KubeChess.Game.Board
    alias KubeChess.Match.Clock
    alias KubeChess.Game.Utilities

    @stalemate    %{ winner: :both,   reason: :stalemate }
    @noending     %{ winner: nil,     reason: nil        }

    defstruct [
        history: [],
        board:   %Board{},
        players: %{ white: nil, black: nil, spectators: MapSet.new(), },
        ending:  %{ winner: nil, reason: nil },
        pending: %{ offer_type: nil, requester: nil },
        clock: %{
            increment: 5,
            game_start: nil,
            game_end: nil,
            white_timeout_treshold: nil,
            black_timeout_treshold: nil,
        }
    ]

    def new(time, increment, white, black), do: %__MODULE__{
        board: %Board{},
        clock: Clock.new(time, increment),
        players: %{
            white: white,
            black: black,
            spectators: MapSet.new(),
        },
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
        {color, opponent} = { state.board.turn, Utilities.opponent(state.board.turn) }
        checkmate_ending = %{ state.ending | winner: color, reason: :checkmate }
        timeout_ending = %{ state.ending | winner: opponent, reason: :timeout }
        king_status = Board.king_status(state.board, color)
        cond do
            Clock.player_timed_out?(state, color) -> timeout_ending
            king_status == :checkmate -> checkmate_ending
            king_status == :stalemate -> @stalemate
            true -> @noending
        end
    end

    def player_color(state, uid) do
        cond do
            state.players.white == uid -> :white
            state.players.black == uid -> :black
            true -> nil
        end
    end

end
