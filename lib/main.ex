defmodule Dero.Main do
    use Application

    defp cluster do
        [
            dero_cluster: [
                strategy: Cluster.Strategy.Epmd,
                config: [
                    hosts: [
                        :"a@127.0.0.1",
                        :"b@127.0.0.1",
                        :"c@127.0.0.1"
                    ]
                ]
            ]
        ]
    end

    defp children do
        [
            {Cluster.Supervisor, [cluster(), [name: :cluster_nodes_supervisor]]},
            {Horde.Registry, [name: :cluster_registry, keys: :unique, members: :auto]},
            {Horde.DynamicSupervisor, [
                name: :cluster_processes_supervisor,
                strategy: :one_for_one,
                members: :auto
            ]},
            Dero.HordeStarter
        ]
    end

    @impl true
    def start(_type, _args) do
        Supervisor.start_link(children(), strategy: :one_for_one)
    end
end
