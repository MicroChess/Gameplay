defmodule KubeChess.Build do
    use Mix.Project

    def project do
        [
            app: :clusterchess_backend,
            version: "0.1.0",
            elixir: "~> 1.19",
            start_permanent: Mix.env() == :prod,
            deps: [
                {:libcluster, "~> 3.4"},
                {:horde, "~> 0.9.0"},
                {:joken, "~> 2.6"},
                {:bandit, "~> 1.0"},
                {:websock, "~> 0.5"},
                {:plug, "~> 1.14"},
                {:jason, "~> 1.4"},
                {:msgpax, "~> 2.3"}
            ]
        ]
    end

    def application do
        [
            extra_applications: [:logger],
            mod: {KubeChess.Main.Startup, []}
        ]
    end
end
