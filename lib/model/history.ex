defmodule History do

    defstruct [
        type:   "starting",
        fen:     Encoding.encode_fen(%Board{}),
        sender:  nil,
        valid:   true,
        prev:    nil,
    ]

    def new(board), do: %History{
        fen: Encoding.encode_fen(board)
    }

    def register_move(history, board), do: %History{
        type: "move",
        fen: Encoding.encode_fen(board),
        sender: Atom.to_string(Squares.opponent_color(board.turn)),
        valid: true,
        prev: history
    }

    def register_info(history, msg_type, sent_by), do: %History{
        type: msg_type,
        fen: history.fen,
        sender: Atom.to_string(sent_by),
        valid: true,
        prev: history
    }

    def revoke_latest_move(%History{} = history) do
        current_is_latest = history.type == "move" and history.valid == true
        case current_is_latest do
            true ->  %History{ history | valid: false }
            false -> %History{ history | prev: revoke_latest_move(history.prev) }
        end
    end

    def latest_fen(%History{} = history) do
        current_is_latest = history.type == "move" and history.valid == true
        case current_is_latest do
            true ->  history.fen
            false -> latest_fen(history.prev)
        end
    end

    def rollout(%History{prev: prev} = history) do
        trimmed = Map.delete(history, :prev) |> Map.delete(:__struct__)
        case prev do
           nil -> [ trimmed ]
           _   -> [ trimmed ] ++ rollout(prev)
        end
    end

    def roll_in([ head | tail ]), do: %History{
        type:   Map.get(head, "type")   || Map.get(head, :type),
        fen:    Map.get(head, "fen")    || Map.get(head, :fen),
        sender: Map.get(head, "sender") || Map.get(head, :sender),
        valid:  Map.get(head, "valid")  || Map.get(head, :valid),
        prev: case tail do
            [] -> nil
            _  -> roll_in(tail)
        end
    }
end
