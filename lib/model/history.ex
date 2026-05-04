defmodule History do

    @starting %{
        type: "starting",
        fen: Serialization.encode_fen(%Board{})
    }

    defstruct [
        version: 1,
        entries: [ @starting ]
    ]

    def new(board), do: [
        %{
            type: "starting",
            fen: Serialization.encode_fen(board)
        }
    ]

    defp wrap(raw_history) do
        %__MODULE__{
            version: 1,
            entries: raw_history
        }
    end

    def register_undo(history, sent_by),
        do: register_undo_helper(history.entries, sent_by)

    defp register_undo_helper([%{ type: "move", fen: fen } | tail], sent_by) do
        undo_entry = %{ type: "undo", fen: fen, sent_by: sent_by }
        { wrap([undo_entry | tail]), fen }
    end

    defp register_undo_helper([head | tail], sent_by) do
        { remaining, fen } = register_undo(tail, sent_by)
        { [head | remaining], fen }
    end

    def register_move(history, board) do
        fen = Serialization.encode_fen(board)
        move_entry = %{ type: "move", fen: fen, sent_by: board.turn }
        { wrap(history.entries ++ [move_entry]), fen }
    end

    def register_communication(history, msg_type, sent_by) do
        communication_entry = %{ type: msg_type, sent_by: sent_by }
        { _, last_active_fen } = register_undo(history, sent_by)
        { wrap(history.entries ++ [communication_entry]), last_active_fen }
    end
end
