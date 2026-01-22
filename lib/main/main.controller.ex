defmodule ClusterChess.Main.Controller do

    def launch(name) do
        Horde.DynamicSupervisor.start_child(
            :cluster_processes_supervisor,
            %{
                id: name,
                start: {ClusterChess.MatchMaking.Queue, :start_link, [name]},
                restart: :transient
            }
        )
    end

    def mailbox(name) do
        case Horde.Registry.lookup(:cluster_registry, name) do
            [{pid, _}] -> :erlang.process_info(pid, :message_queue_len)
            [] -> {:error, :not_found}
        end
    end

    def monitor() do
        Horde.DynamicSupervisor.which_children(:cluster_processes_supervisor)
    end

    def notify(name, message) do
        GenServer.cast(
            {:via, Horde.Registry, {:cluster_registry, name}},
            message
        )
    end

    def call(name, message) do
        GenServer.call(
            {:via, Horde.Registry, {:cluster_registry, name}},
            message
        )
    end
end
