defmodule Dero.Build do
    use Mix.Project

    def project do
        [
            app: :dero,
            version: "0.1.0",
            elixir: "~> 1.19",
            start_permanent: Mix.env() == :prod,
            deps: [
                {:libcluster, "~> 3.4"},
                {:horde, "~> 0.9.0"}
            ]
        ]
    end

    def application do
        [
            extra_applications: [:logger],
            mod: {Dero.Main, []}
        ]
    end
end
