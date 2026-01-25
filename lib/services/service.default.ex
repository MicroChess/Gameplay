defmodule ClusterChess.Services.Default do
    defmacro __using__([registry: registry, initial_state: initial_state]) do
        quote do
            @behaviour GenServer

            def start_link(name) do
                IO.puts("Starting #{__MODULE__} with name #{name}")
                GenServer.start_link(__MODULE__, unquote(initial_state), name:
                    {:via, Horde.Registry, {unquote(registry), name}})
            end

            @impl GenServer
            def init(state) do
                IO.puts("------------------------------------------")
                IO.puts("#{__MODULE__} just started")
                IO.puts("Current state: #{inspect(state)}")
                IO.puts("Current process: #{inspect(self())}")
                IO.puts("------------------------------------------")
                {:ok, state}
            end

            @impl GenServer
            def handle_cast(:crash, state) do
                IO.puts("------------------------------------------")
                IO.puts("Received crash command")
                IO.puts("Current state: #{inspect(state)}")
                IO.puts("Current process: #{inspect(self())}")
                IO.puts("------------------------------------------")
                raise "boom"
                {:noreply, state}
            end

            @impl GenServer
            def handle_cast(message, state) do
                IO.puts("------------------------------------------")
                IO.puts("Received cast message: #{inspect(message)}")
                IO.puts("Current state: #{inspect(state)}")
                IO.puts("Current process: #{inspect(self())}")
                IO.puts("------------------------------------------")
                {:noreply, state}
            end

            @impl GenServer
            def handle_call(request, from, state) do
                IO.puts("------------------------------------------")
                IO.puts("Received call: #{inspect(request)}")
                IO.puts("From: #{inspect(from)}")
                IO.puts("Current state: #{inspect(state)}")
                IO.puts("Current process: #{inspect(self())}")
                IO.puts("------------------------------------------")
                {:reply, {:ok, request}, state}
            end

            defoverridable init: 1, handle_cast: 2, handle_call: 3
        end
    end
end
