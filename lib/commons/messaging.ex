defmodule KubeChess.Commons.Messaging do

    def summon_and_delegate(module, msg, opts),
        do: summon_and_delegate(module, msg, opts, opts)

    def summon_and_delegate(module, msg, opts, id) do
        case get_or_spawn(module, opts, id) |> GenServer.call(msg) do
            :ok -> {:ok, :ack}
            {:ok, something} -> {:ok, something}
            _ -> summon_and_delegate(module, msg, opts, id)
        end
    end

    def search_and_delegate(module, msg, id) do
        case Horde.Registry.lookup(module, id) do
            [{pid, _}] -> {:ok, GenServer.call(pid, msg)}
            _ -> {:error, "#{module} not found"}
        end
    end

    defp get_or_spawn(module, opts, id) do
        settings = {module, :start_link, opts}
        outcome = Horde.DynamicSupervisor.start_child(
            :cluster_processes_supervisor,
            %{ id: id, restart: :transient, start: settings}
        )
        case outcome do
            {:ok, pid} -> pid
            {:error, {:already_started, pid}} -> pid
        end
    end
end
