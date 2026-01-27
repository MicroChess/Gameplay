defmodule ClusterChess.Datapacks.GameCommunication do

    use ClusterChess.Datapacks.Default
    alias ClusterChess.Datapacks.Behaviour

    @derive Jason.Encoder
    defstruct [
        :type,
        :token,
        :game,
        :count,
    ]

    @impl Behaviour
    def id(self),
        do: self.count |>
          Integer.to_string()
end
