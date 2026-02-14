defmodule ClusterChess.Gameplay.State do

    alias ClusterChess.Rules.MakeMoves
    alias ClusterChess.Rules.Board
    alias ClusterChess.Rules.Utilities

    @nopending %{ offer_type: nil, requester: nil }
    @noending %{ winner: nil, reason: nil }
    @white_resign %{ winner: :black, reason: :resignation }
    @black_resign %{ winner: :white, reason: :resignation }
    @stalemate %{ winner: :both, reason: :stalemate }

    defstruct [
        board: %{},
        history: [],
        clock: %{
            increment: nil,
            game_start: nil,
            game_end: nil,
            white_timeout_treshold: nil,
            black_timeout_treshold: nil,
        },
        players: %{
            white: nil,
            black: nil,
            spectators: MapSet.new(),
        },
        ending: %{
            winner: nil,
            reason: nil
        },
        pending: %{
            offer_type: nil,
            requester: nil
        }
    ]

    def update_spectators(state, from) do
        update_in(state.spectators, fn set ->
            old = set || MapSet.new()
            expansion = MapSet.new([from])
            MapSet.union(old, expansion)
        end)
    end

    def apply_move(state, req) do
        now = DateTime.utc_now() |> DateTime.to_unix()
        out = MakeMoves.apply_move(state.board, req.from, req.to)
        {piece, color} = Map.get(state.board.squares, req.from, {nil, nil})
        log = {:move, piece, color, req.from, req.to, now}
        cond do
            out == :invalid_move       -> {:error, "invalid move"}
            state.ending.winner != nil -> {:error, "game already over"}
            player_timed_out?(state)   -> {:error, "player timed out"}
            true -> {:ok, %{state |
                board:   out,
                history: state.history ++ [log],
                pending: @nopending,
                clock:   update_clock(state, req),
                ending:  update_ending(state, out)
            }}
        end
    end

    def apply_resign(state, req) do
        white_player = state.players.white
        black_player = state.players.black
        cond do
            state.ending.winner != nil -> {:error, "game already over"}
            req.uid == white_player -> {:ok, %{state | ending: @white_resign}}
            req.uid == black_player -> {:ok, %{state | ending: @black_resign}}
            true -> {:error, "invalid resignation"}
        end
    end

    def apply_undo(_state, _req), do: :temporary_stub
    def apply_draw(_state, _req), do: :temporary_stub

    defp player_timed_out?(state) do
        now = DateTime.utc_now() |> DateTime.to_unix()
        white_timeout = state.clock.white_timeout_treshold
        black_timeout = state.clock.black_timeout_treshold
        case {state.board.turn} do
            {:white} when white_timeout != nil -> now > white_timeout
            {:black} when black_timeout != nil -> now > black_timeout
            _ -> false
        end
    end

    defp player_timed_out?(state, player),
        do: player_timed_out?(state)
        and state.board.turn == player

    defp update_clock(state, req) do
        now = DateTime.utc_now() |> DateTime.to_unix()
        increment = state.clock.increment || 0
        white_player = state.players.white
        black_player = state.players.black
        case req["uid"] do
            ^white_player -> %{ state.clock | white_timeout_treshold: now + increment }
            ^black_player -> %{ state.clock | black_timeout_treshold: now + increment }
            _other_player -> state.clock
        end
    end

    defp update_ending(state, board) do
        color = state.board.turn
        king_status = Board.king_status(board, color)
        cond do
            player_timed_out?(state, color) -> timeout_ending!(state.ending, color)
            king_status == :checkmate -> checkmate_ending!(state.ending, color)
            king_status == :stalemate -> @stalemate
            true -> @noending
        end
    end

    defp checkmate_ending!(ending, color),
        do: %{ ending | winner: color, reason: :checkmate }

    defp timeout_ending!(ending, color),
        do: %{ ending | winner: Utilities.opponent(color), reason: :timeout }
end
