defmodule Formatting do

    def struct_to_map(data) do
        cond do
            is_struct(data) -> Map.from_struct(data) |> struct_to_map()
            is_map(data) -> Map.new(data, fn {k, v} -> {k, struct_to_map(v)} end)
            is_list(data) -> Enum.map(data, &struct_to_map/1)
            true -> data
        end
    end

    def enforce(shape, data) do
        keys = Map.keys(struct(shape)) -- [:__struct__]
        string_keys = Enum.map(keys, &to_string/1)
        Morphix.atomorphiform(data, string_keys)
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
