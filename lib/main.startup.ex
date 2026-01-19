defmodule Dero.Main.Startup do
    use Application

    defp cluster do
        [
            dero_cluster: [
                strategy: cluster_strategy(),
                config: cluster_config()
            ]
        ]
    end

    defp cluster_strategy do
        case Mix.env() do
            :dev -> Cluster.Strategy.LocalEpmd
            _ -> Cluster.Strategy.Kubernetes.DNS
        end
    end

    defp cluster_config do
        case Mix.env() do
            :dev -> []
            _ ->
                [
                    service: "dero-cluster",
                    namespace: "clusterchess-backend",
                    polling_interval: 10_000
                ]
        end
    end

    defp ports do
        case Mix.env() do
            :dev -> [port: 4000]
            _ -> [port: 80, ip: {0, 0, 0, 0}]
        end
    end

    defp router do
        :cowboy_router.compile([
            {:_, [
                {"/ws", Dero.Games.WebSockets, []}
            ]}
        ])
    end

    defp children do
        [
            {Cluster.Supervisor, [
                cluster(), [name: :cluster_nodes_supervisor]
            ]},
            {Horde.Registry, [name: :cluster_registry, keys: :unique, members: :auto]},
            {Horde.DynamicSupervisor, [
                name: :cluster_processes_supervisor,
                strategy: :one_for_one,
                members: :auto
            ]},
            %{
                id: :http,
                start: {:cowboy, :start_clear, [
                    :http, ports(), %{env: %{dispatch: router()}}
                ]}
            }
        ]
    end

    @impl true
    def start(_type, _args) do
        Supervisor.start_link(children(), strategy: :one_for_one)
    end
end
