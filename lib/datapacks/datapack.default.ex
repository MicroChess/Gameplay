defmodule ClusterChess.Datapack.Default do
    defmacro __using__(_opts) do
        quote do
            @behaviour ClusterChess.Datapack.Behaviour

            @impl ClusterChess.Datapack.Behaviour
            def encode(struct) do
                Jason.encode!(struct)
            end

            @impl ClusterChess.Datapack.Behaviour
            def decode(json) do
                decoded = Jason.decode!(json)
                struct(__MODULE__, decoded)
            end

            defoverridable encode: 1, decode: 1
        end
    end
end
