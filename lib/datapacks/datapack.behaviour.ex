defmodule ClusterChess.Datapacks.Behaviour do
    @type outcome()
        :: {:ok, struct()}
        |  {:error, String.t()}

    @callback id(struct()) :: String.t()
    @callback enforce(map()) :: outcome()
end
