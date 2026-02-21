defmodule KubeChess.Gameplay.Communication do

    use KubeChess.Commons.Datapack

    @derive Jason.Encoder
    defstruct [
        :type,
        :token,
        :game,
        :count,
    ]

    @impl KubeChess.Commons.Datapack
    def id(self),
        do: self.count |>
          Integer.to_string()
end
