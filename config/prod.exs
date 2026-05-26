import Config

config :microchess_gameplay, mongo_conn:
    :mongo

config :microchess_gameplay, cluster_strategy:
    Cluster.Strategy.Kubernetes.DNS

config :microchess_gameplay, cluster_config: [
    service: "microchess-gameplay-hl",
    namespace: "microchess",
    application_name: "gameplay",
    polling_interval: 10_000
]
