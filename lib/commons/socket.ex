defmodule KubeChess.Commons.Socket do
    defmacro __using__(_opts) do
        quote do
            @behaviour WebSock

            @impl WebSock
            def handle_info({:forward, message}, state) do
                {:reply, :ok, {:text, message}, state}
            end

            @impl WebSock
            def handle_in({_msg, [opcode: protocol]}, state)
                when (protocol not in [:text, :binary]), do: {:ok, state}

            @impl WebSock
            def handle_in({message, [opcode: protocol]}, state) do
                IO.puts("------------------------------------------")
                IO.puts("Message received: #{inspect(message)}")
                IO.puts("Current state: #{inspect(state)}")
                IO.puts("Current process: #{inspect(self())}")
                IO.puts("------------------------------------------")
                {:ok, state}
            end

            @impl WebSock
            def init(options) do
                IO.puts("------------------------------------------")
                IO.puts("Connection established")
                IO.puts("Current options: #{inspect(options)}")
                IO.puts("Current process: #{inspect(self())}")
                IO.puts("------------------------------------------")
                {:ok, options}
            end

            @impl WebSock
            def handle_info(message, state) do
                IO.puts("------------------------------------------")
                IO.puts("Received info message: #{inspect(message)}")
                IO.puts("Current state: #{inspect(state)}")
                IO.puts("Current process: #{inspect(self())}")
                IO.puts("------------------------------------------")
                {:ok, state}
            end

            defoverridable handle_info: 2, handle_in: 2, init: 1
        end
    end
end
