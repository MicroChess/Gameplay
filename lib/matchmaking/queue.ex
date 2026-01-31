defmodule ClusterChess.Matchmaking.Queue do

    use ClusterChess.Commons.Datapack

    @derive Jason.Encoder
    defstruct [
        :type,
        :token,
        :elo,
        :gamemode,
        :minutes,
        :increment
    ]

    @impl ClusterChess.Commons.Datapack
    def id(self) do
        with {:ok, minutes}   <- Map.fetch(self, :minutes),
             {:ok, increment} <- Map.fetch(self, :increment),
             {:ok, gamemode}  <- Map.fetch(self, :gamemode)
        do
            "#{gamemode}-#{minutes}+#{increment}"
        end
    end
end
