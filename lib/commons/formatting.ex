defmodule Commons.Formatting do
    import String, only: [to_atom: 1]

    def contains(list, item) do
        if item in list,
            do: {:ok, item},
            else: {:error, "Unrecognized item: #{item}"}
    end

    def enforce(shapes, data, key) do
        case Map.fetch(shapes, key) do
            {:ok, shape} -> enforce(shape, data)
            _ -> {:error, "Unrecognized shape: #{key}"}
        end
    end

    defp enforce(shape, data) do
        atomic_data = atomize(shape, data)
        atomic_keys = atom_keys(shape)
        contained? = fn key ->
            Map.has_key?(atomic_data, key) and
            not is_nil(Map.get(atomic_data, key))
        end
        case Enum.all?(atomic_keys, contained?) do
            true  -> {:ok, atomic_data}
            false -> {:error, "Invalid Datapack"}
        end
    end

    defp atomize(module, data) do
        keys = string_keys(module) ++ atom_keys(module)
        filtered = Map.take(data, keys)
        for {k, v} <- filtered, into: %{} do
            {(if is_binary(k), do: to_atom(k), else: k), v}
        end
    end

    defp string_keys(x),
        do: atom_keys(x) |> Enum.map(&to_string/1)

    defp atom_keys(module) do
        struct(module, %{})
        |> Map.keys()
        |> Enum.filter(&(&1 != :__struct__))
    end

    def decode!(frame, :text),   do: Jason.decode!(frame)
    def decode!(frame, :binary), do: Msgpax.unpack!(frame)
    def decode(frame, :text),    do: Jason.decode(frame)
    def decode(frame, :binary),  do: Msgpax.unpack(frame)
    def encode!(data, :text),    do: Jason.encode!(data)
    def encode!(data, :binary),  do: Msgpax.pack!(data)

    def resp(msg, protocol, state \\ %{}),
        do: {:reply, :ok, {protocol, msg}, state}

    def error(reason, protocol, state \\ %{}) do
        msg = encode!(%{"error" => inspect(reason)}, protocol)
        {:reply, :ok, {protocol, msg}, state}
    end
end
