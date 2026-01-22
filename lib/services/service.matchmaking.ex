defmodule ClusterChess.Play.Queue do

    use GenServer

    def start_link(name) do
        GenServer.start_link(__MODULE__, [], name:
            {:via, Horde.Registry, {:matchmaking_registry, name}})
    end

    @impl GenServer
    def init(state) do
        IO.puts("#{__MODULE__} started with state: #{inspect(state)} on node #{Node.self()}")
        {:ok, state}
    end

    @impl GenServer
    def handle_cast(:crash, state) do
        IO.puts("Crashing now on node #{Node.self()}...")
        raise "boom"
        {:noreply, state}
    end

    @impl GenServer
    def handle_cast(message, state) do
        IO.puts("Received message: #{inspect(message)} on node #{Node.self()}")
        {:noreply, state}
    end
end
