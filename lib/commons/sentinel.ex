defmodule KubeChess.Commons.Sentinel do
    @behaviour GenServer

    @impl GenServer
    def init(state), do: {:ok, state}

    @impl GenServer
    def handle_cast({:sentinel_plain_forward, msg, recipient}, state),
        do: send(recipient, msg) && {:noreply, state}

    @impl GenServer
    def handle_cast({:sentinel_genserver_forward, msg, recipient}, state),
        do: GenServer.call(recipient, msg) && {:noreply, state}

    @impl GenServer
    def handle_cast(request, state) do
        old_messages = Map.get(state, :messages, [])
        new_messages = old_messages ++ [{request, nil}]
        {:noreply, Map.put(state, :messages, new_messages)}
    end

    @impl GenServer
    def handle_call(:sentinel_plain_describe, _from, state),
        do: {:reply, state, state}

    @impl GenServer
    def handle_call({:sentinel_genserver_forward, msg, recipient}, _from, state),
        do: {:reply, GenServer.call(recipient, msg), state}

    @impl GenServer
    def handle_call(:sentinel_clear_messages, _from, state),
        do: {:reply, :ok, Map.put(state, :messages, [])}

    @impl GenServer
    def handle_call(request, from, state) do
        old_messages = Map.get(state, :messages, [])
        new_messages = old_messages ++ [{request, from}]
        {:reply, :ok, Map.put(state, :messages, new_messages)}
    end

    @impl GenServer
    def handle_info(msg, state),
        do: handle_cast(msg, state)

    def impersonate_and_send(sentinel_pid, msg, recipient),
        do: GenServer.cast(sentinel_pid, {:sentinel_plain_forward, msg, recipient})

    def impersonate_and_call(sentinel_pid, msg, recipient),
        do: GenServer.call(sentinel_pid, {:sentinel_genserver_forward, msg, recipient})

    def impersonate_and_cast(sentinel_pid, msg),
        do: GenServer.cast(sentinel_pid, msg)

    def impersonate_and_describe(sentinel_pid),
        do: GenServer.call(sentinel_pid, :sentinel_plain_describe)

    def clear_messages(sentinel_pid),
        do: GenServer.cast(sentinel_pid, :sentinel_clear_messages)
end
