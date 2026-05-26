import Config

config :microchess_gameplay, mongo_conn:
    :mongo

config :microchess_gameplay, cluster_strategy:
    Cluster.Strategy.Epmd

config :microchess_gameplay, cluster_config:
    [ hosts: [] ]
