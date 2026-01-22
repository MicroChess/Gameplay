defmodule ClusterChess.Sockets.Default do
  alias ClusterChess.Sockets.Commons
    defmacro __using__(_opts) do
        quote do
            @behaviour WebSock
            @behaviour ClusterChess.Sockets.Behaviour

            alias ClusterChess.Sockets.Commons

            @impl WebSock
            def handle_in({_msg, [opcode: protocol]}, state)
                when (protocol not in [:text, :binary]), do: {:ok, state}

            @impl WebSock
            def handle_in({message, [opcode: protocol]}, state) do
                with {:ok, decoded} <- Commons.decode(message, protocol),
                     {:ok, msgtype} <- Map.fetch(decoded, "type"),
                     {:ok, response, new_state}  <- process(msgtype, decoded, state)
                do
                    Commons.encode!(response, protocol) |> Commons.resp(protocol, new_state)
                else
                    {:error, reason, new_state} -> Commons.error(reason, protocol, new_state)
                    _ -> Commons.error("Invalid message format", protocol, state)
                end
            end

            @impl WebSock
            def handle_info({:forward, message}, state) do
                {:reply, :ok, {:text, message}, state}
            end

            @impl WebSock
            def init(options) do
                IO.puts("------------------------------------------")
                IO.puts("Connection enstabilished")
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
