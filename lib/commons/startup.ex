defmodule Startup do

    use Application

    @mongodb_instance Application.compile_env(:microchess_gameplay, :mongo_conn, :mongo)
    @cluster_strategy Application.compile_env(:microchess_gameplay, :cluster_strategy, Cluster.Strategy.Epmd)
    @cluster_config   Application.compile_env(:microchess_gameplay, :cluster_config, [hosts: []])

    @impl Application
    def start(_type, _args) do
        Supervisor.start_link(children(), strategy: :one_for_one)
    end

    defp children(), do: [
        {Cluster.Supervisor, [[
            main_cluster: [
                strategy: @cluster_strategy,
                config: @cluster_config
            ]],
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
            name: @mongodb_instance
        ]},
        {Broker, [
            dispatcher_concurrency: 10,
            consumer_concurrency: 1,
            connection: Application.get_env(:microchess_gameplay, :rabbitmq_connection, [
                host: System.get_env("RABBITMQ_HOST", "localhost"),
                port: String.to_integer(System.get_env("RABBITMQ_PORT", "5672")),
                username: System.get_env("RABBITMQ_USER", "guest"),
                password: System.get_env("RABBITMQ_PASS", "guest")
            ])
        ]}
    ]
end
