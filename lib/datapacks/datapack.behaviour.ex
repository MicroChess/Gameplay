defmodule ClusterChess.Datapack.Behaviour do
    @callback encode(struct()) :: String.t()
    @callback decode(String.t()) :: struct()
end
