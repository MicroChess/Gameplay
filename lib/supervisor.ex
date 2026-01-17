defmodule Dero.Supervisor do
    use Supervisor

    def start_link(init_arg) do
        Supervisor.start_link(__MODULE__, init_arg, name:
            {:via, Horde.Registry, {:cluster_registry, __MODULE__}})
    end

    @impl true
    def init(_init_arg) do
        children = [{Dero.Worker, :initial_state}]
        Supervisor.init(children, strategy: :one_for_one)
    end
end
