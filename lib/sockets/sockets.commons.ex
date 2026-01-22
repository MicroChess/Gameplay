defmodule ClusterChess.Sockets.Commons do

    alias ClusterChess.Main.Validation

    def parse(decoded, _module) do
        with {:ok, authdata} <- Validation.validate_token(decoded["token"]),
             true            <- authdata.uid == decoded["datapack"]["uid"]
        do
                {:ok, decoded["datapack"]}
        else
                {:error, reason} -> {:error, reason}
                _uid_dont_match  -> {:error, "Unauthorized"}
        end
    end

    def delegate(registry, module, name, msg) do
        case Horde.Registry.lookup(registry, name) do
            [{pid, _value}] -> GenServer.call(pid, {:delegate, msg})
            [] -> start_worker(module, name) |> GenServer.call({:delegate, msg})
        end
    end

    def error!(reason, :text),   do: Jason.encode!(%{"error" => reason})
    def error!(reason, :binary), do: Msgpax.pack!(%{"error" => reason})
    def decode!(frame, :text),   do: Jason.decode!(frame)
    def decode!(frame, :binary), do: Msgpax.unpack!(frame)
    def decode(frame,  :text),   do: Jason.decode(frame)
    def decode(frame,  :binary), do: Msgpax.unpack(frame)
    def encode!(data,  :text),   do: Jason.encode!(data)
    def encode!(data,  :binary), do: Msgpax.pack!(data)

    defp start_worker(module, name) do
        descriptor = {module, :start_link, [name]}
        worker_creation = Horde.DynamicSupervisor.start_child(
            :cluster_processes_supervisor,
            %{id: name, start: descriptor, restart: :transient}
        )
        case worker_creation do
            {:ok, pid} -> pid
            {:error, reason} -> {:error, reason}
        end
    end
end
