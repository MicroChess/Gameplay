defmodule Clock do

    defstruct [
        config: %{
            increment:     -1,
            initial_time:  -1,
        },
        timers: %{
            white:         -1,
            black:         -1,
        },
        timestamps: %{
            white:         nil,
            black:         nil,
        }
    ]

    def new(start_mins, increment_s), do: %__MODULE__{
        config: %{
            increment:    increment_s,
            initial_time: start_mins,
        },
        timers: %{
            white: start_mins * 60 * 1000,
            black: start_mins * 60 * 1000,
        },
        timestamps: %{
            white: nil,
            black: nil,
        }
    }

    def game_timed_out?(state),
        do: player_timed_out?(state, :white)
        or  player_timed_out?(state, :black)

    def player_timed_out?(state, color),
        do: time_after_move(state, color, now_milliseconds()) <= 0

    def minimum_time_left(state) do
        now_timestamp = now_milliseconds()
        white_time_left = time_after_move(state, :white, now_timestamp)
        black_time_left = time_after_move(state, :black, now_timestamp)
        min(white_time_left, black_time_left)
    end

    def update_clock(state, color) do
        now_timestamp = now_milliseconds()
        millis_left = time_after_move(state, color, now_timestamp)
        millis_left_after_move = millis_left + state.clock.config.increment * 1000
        %Clock{
            config: state.clock.config,
            timers: Map.put(state.clock.timers, color, millis_left_after_move),
            timestamps: Map.put(state.clock.timestamps, color, now_timestamp),
        }
    end

    def milliseconds_on_the_clock(state, color),
        do: time_after_move(state, color, now_milliseconds())

    def time_after_move(state, color, now_timestamp) do
        millis_on_the_clock = Map.fetch!(state.clock.timers, color)
        prev_move_timestamp = Map.fetch!(state.clock.timestamps, color) || now_timestamp
        time_took_to_move = now_timestamp - prev_move_timestamp
        millis_on_the_clock - time_took_to_move
    end

    defp now_milliseconds(),
        do: DateTime.utc_now()
        |>  DateTime.to_unix(:millisecond)
end
