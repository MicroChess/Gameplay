defmodule ClusterChess.Sockets.Commons do

    alias ClusterChess.Main.Validation

    def parse(decoded, _module) do
        case Validation.validate_token(decoded["token"]) do
            :ok -> {:ok, decoded}
            {:ok, _} -> {:ok, decoded}
            {:error, reason} -> {:error, reason}
            _generic_error -> {:error, "Unauthorized"}
        end
    end

    def delegate(module, name, msg) do
        case get_worker(module, name) |> GenServer.call(msg) do
            :ok -> {:ok, :ack}
            {:ok, something} -> {:ok, something}
            _ -> delegate(module, name, msg)
        end
    end

    defp get_worker(module, name) do
        settings = {module, :start_link, [name]}
        outcome = Horde.DynamicSupervisor.start_child(
            :cluster_processes_supervisor,
            %{ id: name, restart: :transient, start: settings}
        )
        case outcome do
            {:ok, pid} -> pid
            {:error, {:already_started, pid}} -> pid
        end
    end

    def error!(reason, :text),   do: Jason.encode!(%{"error" => reason})
    def error!(reason, :binary), do: Msgpax.pack!(%{"error" => reason})
    def decode!(frame, :text),   do: Jason.decode!(frame)
    def decode!(frame, :binary), do: Msgpax.unpack!(frame)
    def decode(frame, :text),    do: Jason.decode(frame)
    def decode(frame, :binary),  do: Msgpax.unpack(frame)
    def encode!(data, :text),    do: Jason.encode!(data)
    def encode!(data, :binary),  do: Msgpax.pack!(data)
end
