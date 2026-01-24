defmodule ClusterChess.Datapacks.Queue do

    use ClusterChess.Datapacks.Default
    alias ClusterChess.Datapacks.Behaviour

    @derive Jason.Encoder
    defstruct [
        :token,
        :rating,
        :preferred_color,
        :required_color,
        :ranked,
        :minutes,
        :increment
    ]

    defp ranked_2str(true),  do: "ranked"
    defp ranked_2str(false), do: "unranked"

    @impl Behaviour
    def id(self) do
        with {:ok, minutes}   <- Map.fetch(self, :minutes),
             {:ok, increment} <- Map.fetch(self, :increment),
             {:ok, ranked}    <- Map.fetch(self, :ranked)
        do
            {:ok, "#{ranked_2str(ranked)}-#{minutes}+#{increment}"}
        else
            _ -> {:error, "Missing key fields"}
        end
    end
end
