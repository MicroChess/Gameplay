defmodule ClusterChess.Sockets.Behaviour do

    @type state         :: map()
    @type reason        :: String.t()
    @type label         :: String.t()
    @type datapack      :: map() | struct()

    @callback process(label(), datapack(), state())
        :: {:ok, state(), datapack()}
        |  {:error, state(), reason()}

end
