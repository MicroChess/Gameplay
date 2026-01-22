defmodule ClusterChess.Datapacks.Queue do

    use ClusterChess.Datapack.Default
    alias ClusterChess.Datapack.Behaviour

    @derive Jason.Encoder
    defstruct [
        :token,
        :rating,
        :preferred_color,
        :required_color,
        :ranked,
        :timeformat,
        :increment
    ]

    @impl Behaviour
    def getkey(self) do
        with {:ok, timeformat} <- Map.fetch(self, :timeformat),
             {:ok, increment}  <- Map.fetch(self, :increment),
             {:ok, ranked}     <- Map.fetch(self, :ranked)
        do
            {:ok, "#{ranked}-#{timeformat}+#{increment}"}
        else
            _ -> {:error, "Missing key fields"}
        end
    end
end
