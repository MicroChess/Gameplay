defmodule KubeChess.Gameplay.DoMove do

    use KubeChess.Commons.Datapack

    @derive Jason.Encoder
    defstruct [
        :type,
        :token,
        :game,
        :count,
        :from,
        :to,
        :promotion
    ]

    @impl KubeChess.Commons.Datapack
    def id(self),
        do: self.move_count |>
          Integer.to_string()
end
