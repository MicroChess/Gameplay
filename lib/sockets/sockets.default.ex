defmodule ClusterChess.Sockets.Default do
    defmacro __using__(_opts) do
        quote do
            @behaviour WebSock
            @behaviour ClusterChess.Sockets.Behaviour

            alias ClusterChess.Sockets.Commons

            @impl WebSock
            def handle_in({_msg, [opcode: opcode]}, state)
                when (opcode not in [:text, :binary]), do: {:ok, state}

            @impl WebSock
            def handle_in({message, [opcode: opcode]}, state) do
                with {:ok, decoded} <- Commons.decode(message, opcode),
                     {:ok, msgtype} <- Map.fetch(decoded, "type"),
                     {:ok, xr, xs}  <- process(msgtype, decoded, state)
                do
                    {:reply, :ok, {opcode, Commons.encode!(xr, opcode)}, xs}
                else
                    {:error, reason, xs} -> {:reply, :ok, {opcode, Commons.error!(reason, opcode)}, xs}
                    _ -> {:reply, :ok, {opcode, Commons.error!("Illformed", opcode)}, state}
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
        end
    end
end
