defmodule ClusterChess.Sockets.Commons do

    def contains(list, item) do
        if item in list,
            do: {:ok, item},
            else: {:error, "Unrecognized item: #{item}"}
    end

    def enforce(shapes, data, key) do
        case Map.fetch(shapes, key) do
            {:ok, shape} -> shape.enforce(data)
            _ -> {:error, "Unrecognized shape: #{key}"}
        end
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
