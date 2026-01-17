defmodule Dero.Worker do
    use GenServer

    def start_link(init_arg) do
        GenServer.start_link(__MODULE__, init_arg, name:
            {:via, Horde.Registry, {:cluster_registry, __MODULE__}})
    end

    def crash do
        GenServer.cast(
            {:via, Horde.Registry, {:cluster_registry, __MODULE__}},
            :crash
        )
    end

    @impl true
    def init(state) do
        IO.puts("Dero.Worker started with state: #{inspect(state)} on node #{Node.self()}")
        {:ok, state}
    end

    @impl true
    def handle_cast(:crash, state) do
        IO.puts("Crashing now on node #{Node.self()}...")
        raise "boom"
        {:noreply, state}
    end
end
