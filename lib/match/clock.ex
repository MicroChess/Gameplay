defmodule KubeChess.Match.Clock do

    defstruct [
        increment: 5,
        game_start: nil,
        game_end: nil,
        white_timeout_treshold: nil,
        black_timeout_treshold: nil
    ]

    def new(treshold, increment), do: %__MODULE__{
        increment: increment,
        game_start: now(),
        game_end: nil,
        white_timeout_treshold: now() + treshold,
        black_timeout_treshold: now() + treshold
    }

    def game_timed_out?(state) do
        white_timeout = state.clock.white_timeout_treshold
        black_timeout = state.clock.black_timeout_treshold
        case {state.board.turn} do
            {:white} when white_timeout != nil -> now() > white_timeout
            {:black} when black_timeout != nil -> now() > black_timeout
            _ -> false
        end
    end

    def player_timed_out?(state, player),
        do: game_timed_out?(state)
        and state.board.turn == player

    def update_clock(state, color) do
        increment = state.clock.increment || 0
        case color do
            :white -> %{ state.clock | white_timeout_treshold: now() + increment }
            :black -> %{ state.clock | black_timeout_treshold: now() + increment }
            _other_player -> state.clock
        end
    end

    def now(),
        do: DateTime.utc_now()
        |>  DateTime.to_unix()
end
