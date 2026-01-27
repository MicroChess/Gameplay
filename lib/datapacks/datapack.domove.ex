defmodule ClusterChess.Datapacks.DoMove do

    use ClusterChess.Datapacks.Default
    alias ClusterChess.Datapacks.Behaviour

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

    @impl Behaviour
    def id(self),
        do: self.move_count |>
          Integer.to_string()
end
