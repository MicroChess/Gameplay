defmodule ClusterChess.Main.Sockets do
    @behaviour WebSock

    @impl WebSock
    def init(options) do
        IO.puts("Connected")
        IO.puts(options |> inspect())
        #Registry.register(:socket_registry, options.user_id, %{})
        {:ok, options}
    end

    @impl WebSock
    def handle_in({"ping", [opcode: :text]}, state) do
        {:reply, :ok, {:text, "pong"}, state}
    end

    @impl WebSock
    def handle_in({message, [opcode: :text]}, state) do
        {:reply, :ok, {:text, "You said: #{message}"}, state}
    end

    @impl WebSock
    def handle_in(_frame, state) do
        {:ok, state}
    end

    @impl WebSock
    def handle_info(_message, state) do
        {:ok, state}
    end

    @impl WebSock
    def terminate(_reason, _state) do
        :ok
    end
end
