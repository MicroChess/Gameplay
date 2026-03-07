defmodule Build do
    use Mix.Project

    def project do
        [
            app: :microchess_gameplay,
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
                {:msgpax, "~> 2.3"},
                {:mongodb, "~> 1.0"}
            ]
        ]
    end

    def application do
        [
            extra_applications: [:logger],
            mod: {Startup, []}
        ]
    end
end
