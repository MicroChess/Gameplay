import Config

config :microchess_gameplay, mongo_conn:
    :mongo_test

config :microchess_gameplay, cluster_strategy:
    Cluster.Strategy.Epmd

config :microchess_gameplay, cluster_config:
    [ hosts: [] ]
