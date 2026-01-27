defmodule ClusterChess.Datapacks.Queue do

    use ClusterChess.Datapacks.Default
    alias ClusterChess.Datapacks.Behaviour

    @derive Jason.Encoder
    defstruct [
        :type,
        :token,
        :elo,
        :gamemode,
        :minutes,
        :increment
    ]

    @impl Behaviour
    def id(self) do
        with {:ok, minutes}   <- Map.fetch(self, :minutes),
             {:ok, increment} <- Map.fetch(self, :increment),
             {:ok, gamemode}  <- Map.fetch(self, :gamemode)
        do
            {:ok, "#{gamemode}-#{minutes}+#{increment}"}
        else
            _ -> {:error, "Missing key fields"}
        end
    end
end
