defmodule ClusterChess.Datapacks.Queue do

    use ClusterChess.Datapack.Default
    alias ClusterChess.Datapack.Behaviour

    @derive Jason.Encoder
    defstruct [
        :token,
        :rating,
        :preferred_color,
        :required_color,
        :timeformat,
        :increment
    ]

    @impl Behaviour
    def enforce(data) do
        struct = struct(__MODULE__, data)
        ok? = struct |> Map.values() |> Enum.all?(&(!is_nil(&1)))
        if ok?, do: {:ok, struct}, else: {:error, "Invalid datapack"}
    end

    @impl Behaviour
    def getkey(self) do
        with {:ok, timeformat} <- Map.fetch(self, :timeformat),
             {:ok, increment}  <- Map.fetch(self, :increment)
        do
            {:ok, "#{timeformat}+#{increment}"}
        else
            _ -> {:error, "Missing key fields"}
        end
    end
end
