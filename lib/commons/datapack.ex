defmodule KubeChess.Commons.Datapack do

    @type outcome()
        :: {:ok, struct()}
        |  {:error, String.t()}

    @callback id(struct()) :: String.t()
    @callback enforce(map()) :: outcome()

    defmacro __using__(_opts) do
        quote do
            @behaviour KubeChess.Commons.Datapack
            alias KubeChess.Commons.Formatting

            @impl KubeChess.Commons.Datapack
            def enforce(data) do
                atomic_data = Formatting.atomize(__MODULE__, data)
                atomic_keys = Formatting.atom_keys(__MODULE__)
                contained? = fn key ->
                    Map.has_key?(atomic_data, key) and
                    not is_nil(Map.get(atomic_data, key))
                end
                case Enum.all?(atomic_keys, contained?) do
                    true  -> {:ok, atomic_data}
                    false -> {:error, "Invalid Datapack"}
                end
            end

            defoverridable enforce: 1
        end
    end
end
