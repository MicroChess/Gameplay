defmodule ClusterChess.Gameplay.State do

    defstruct [
        board: %{},
        turn: :white,
        castling_rights: %{
            white_lx: true,
            white_sx: true,
            black_lx: true,
            black_sx: true
        },
        en_passant_target: nil,
        count: 0,
        overall_clock: 0,
        white_clock: 0,
        black_clock: 0,
        white_player: nil,
        black_player: nil
    ]
end
