defmodule ClusterChess.Datapack.Behaviour do

    @type outcome()
        :: {:ok, struct()}
        |  {:error, String.t()}

    @callback encode(struct())   :: String.t()
    @callback getkey(struct())   :: String.t()
    @callback enforce(map())     :: outcome()
    @callback decode(String.t()) :: struct()
end
