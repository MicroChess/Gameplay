defmodule Build do

    use Mix.Project

    def project, do: [
        app: :microchess_gameplay,
        version: "0.1.0",
        elixir: "~> 1.19",
        start_permanent: Mix.env() == :prod,
        aliases: aliases(),
        deps: [
            {:libcluster, "~> 3.4"},
            {:horde, "~> 0.9.0"},
            {:joken, "~> 2.6"},
            {:bandit, "~> 1.0"},
            {:websock, "~> 0.5"},
            {:plug, "~> 1.14"},
            {:jason, "~> 1.4"},
            {:msgpax, "~> 2.3"},
            {:mongodb_driver, "~> 1.5"},
            {:broadway_rabbitmq, "~> 0.8"},
            {:morphix, "~> 0.8.0"}
        ]
    ]

    def cli, do: [
        preferred_envs: [
            "test.local":     :test,
            "test.nosandbox": :test,
            "test.clean":     :test,
            test:             :test
        ]
    ]

    def application, do: [
        extra_applications: [:logger],
        mod: {Startup, []}
    ]

    defp aliases, do: [
        "test.nosandbox": [
            &Mix.Tasks.Test.run/1
        ],
        "test.local": [
            fn _args -> Mix.Tasks.Test.run([
                "test/events",
                "test/model",
                "test/moves"
            ]) end
        ],
        "test.clean": [
            "cmd docker compose -f docker/compose.yml down "
        ],
        test: [
            "cmd docker compose -f docker/compose.yml up " <>
            "--abort-on-container-exit "                   <>
            "--exit-code-from gameplay-test "              <>
            "--attach gameplay-test "                      <>
            "--no-log-prefix "
        ],
    ]
end
