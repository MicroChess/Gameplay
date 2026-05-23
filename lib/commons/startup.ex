defmodule Startup do

    use Application

    @impl Application
    def start(_type, _args) do
        Supervisor.start_link(children(), strategy: :one_for_one)
    end

    defp children do
        [
            {Cluster.Supervisor, [
                cluster(),
                [name: :cluster_nodes_supervisor]
            ]},
            {Horde.Registry, [
                name: :matchmaking_registry,
                keys: :unique,
                members: :auto
            ]},
            {Horde.Registry, [
                name: :gameplay_registry,
                keys: :unique,
                members: :auto
            ]},
            {Horde.DynamicSupervisor, [
                name: :cluster_processes_supervisor,
                strategy: :one_for_one,
                members: :auto
            ]},
            {Bandit, [
                port: String.to_integer(System.get_env("port", "4000")),
                plug: Router,
                ip: {0, 0, 0, 0}
            ]},
            {Mongo, [
                url: System.get_env("MONGODB_URL", "mongodb://localhost:27017/games"),
                name: :mongo
            ]},
            {Broker, [
                dispatcher_concurrency: 10,
                consumer_concurrency: 1,
                connection: [
                    host: System.get_env("RABBITMQ_HOST", "localhost"),
                    port: String.to_integer(System.get_env("RABBITMQ_PORT", "5672")),
                    username: System.get_env("RABBITMQ_USER", "guest"),
                    password: System.get_env("RABBITMQ_PASS", "guest")
                ]
            ]}
        ]
    end

    defp cluster do
        [
            main_cluster: [
                strategy: cluster_strategy(),
                config: cluster_config()
            ]
        ]
    end

    defp cluster_strategy do
        case System.get_env("strategy", "none") do
            "none"  -> Cluster.Strategy.Epmd
            "local" -> Cluster.Strategy.LocalEpmd
            "kube"  -> Cluster.Strategy.Kubernetes.DNS
            _ -> raise "Unknown clustering strategy"
        end
    end

    defp cluster_config do
        case System.get_env("strategy", "none") do
            "none"  -> [ hosts: [] ]
            "local" -> []
            "kube"  ->
                [
                    service: "microchess-gameplay-hl",
                    namespace: "microchess",
                    application_name: "gameplay",
                    polling_interval: 10_000
                ]
            _ -> raise "Unknown clustering strategy"
        end
    end
end
