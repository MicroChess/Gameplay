defmodule ClusterChess.Datapacks.Default do
    defmacro __using__(_opts) do
        quote do
            @behaviour ClusterChess.Datapacks.Behaviour
            import String, only: [to_atom: 1]

            @impl ClusterChess.Datapacks.Behaviour
            def enforce(data) do
                atomic_data = atomize(data)
                atomic_keys = atom_keys()
                contained? = fn key ->
                    Map.has_key?(atomic_data, key) and
                    not is_nil(Map.get(atomic_data, key))
                end
                case Enum.all?(atomic_keys, contained?) do
                    true  -> {:ok, atomic_data}
                    false -> {:error, "Invalid Datapack"}
                end
            end

            defp atomize(data) do
                keys = string_keys() ++ atom_keys()
                filtered = Map.take(data, keys)
                for {k, v} <- filtered, into: %{} do
                    {(if is_binary(k), do: to_atom(k), else: k), v}
                end
            end

            defp string_keys() do
                atom_keys()
                |> Enum.map(&to_string/1)
            end

            defp atom_keys() do
                struct(__MODULE__, %{})
                |> Map.keys()
                |> Enum.filter(&(&1 != :__struct__))
            end

            defoverridable enforce: 1
        end
    end
end
