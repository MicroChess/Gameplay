defmodule ClusterChess.Gameplay.State do

    alias ClusterChess.Gameplay.Fen
    alias ClusterChess.Rules.MakeMoves
    alias ClusterChess.Rules.Board
    alias ClusterChess.Rules.Utilities

    @nopending %{ offer_type: nil, requester: nil }
    @noending %{ winner: nil, reason: nil }
    @white_resign %{ winner: :black, reason: :resignation }
    @black_resign %{ winner: :white, reason: :resignation }
    @stalemate %{ winner: :both, reason: :stalemate }

    @starting_fen_string "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w"
    @starting_position Fen.fen_to_map(@starting_fen_string)

    defstruct [
        history: [],
        board: %Board{squares: @starting_position},
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

    def apply_move(state, req) do
        {from, to} = {req.from, req.to}
        out = MakeMoves.apply_move(state.board, from, to)
        {piece, color} = Map.get(state.board.squares, from, {nil, nil})
        log = {:move, piece, color, from, to, now()}
        cond do
            out == :invalid_move       -> {:error, "invalid move"}
            state.ending.winner != nil -> {:error, "game already over"}
            game_timed_out?(state)     -> {:error, "player timed out"}
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

    def apply_draw(state, req) do
        white_player = state.players.white
        black_player = state.players.black
        draw_req_ack = %{ state | pending: %{ offer_type: :draw, requester: req.uid } }
        draw_accept = %{ state | pending: @nopending, ending: @stalemate }
        cond do
            req.uid not in [white_player, black_player] -> {:error, "forbidden: not a player"}
            state.ending.winner != nil -> {:error, "game already over"}
            state.pending.offer_type == nil -> {:ok, draw_req_ack }
            state.pending.offer_type != :draw -> {:ok, draw_req_ack }
            state.pending.requester != req.uid -> {:ok, draw_accept}
            true -> {:error, "invalid draw offer"}
        end
    end

    defp game_timed_out?(state) do
        white_timeout = state.clock.white_timeout_treshold
        black_timeout = state.clock.black_timeout_treshold
        case {state.board.turn} do
            {:white} when white_timeout != nil -> now() > white_timeout
            {:black} when black_timeout != nil -> now() > black_timeout
            _ -> false
        end
    end

    defp player_timed_out?(state, player),
        do: game_timed_out?(state)
        and state.board.turn == player

    defp update_clock(state, req) do
        increment = state.clock.increment || 0
        white_player = state.players.white
        black_player = state.players.black
        case req.uid do
            ^white_player -> %{ state.clock | white_timeout_treshold: now() + increment }
            ^black_player -> %{ state.clock | black_timeout_treshold: now() + increment }
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

    def new(time, increment, white, black), do: %__MODULE__{
        board: %Board{squares: @starting_position},
        clock: %{
            increment: increment,
            game_start: now(),
            game_end: nil,
            white_timeout_treshold: now() + time,
            black_timeout_treshold: now() + time,
        },
        players: %{
            white: white,
            black: black,
            spectators: MapSet.new(),
        },
    }

    def now(),
        do: DateTime.utc_now() |> DateTime.to_unix()

    defp checkmate_ending!(ending, color),
        do: %{ ending | winner: color, reason: :checkmate }

    defp timeout_ending!(ending, color),
        do: %{ ending | winner: Utilities.opponent(color), reason: :timeout }
end
