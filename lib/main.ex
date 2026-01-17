defmodule Dero.Main do
    use Application

    def start(_type, _args) do
        Dero.Example.hello()
        children = [{Dero.Supervisor, []}]
        Supervisor.start_link(children, strategy: :one_for_one)
    end
end
