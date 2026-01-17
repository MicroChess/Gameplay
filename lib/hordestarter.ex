defmodule Dero.HordeStarter do
    use GenServer

    def start_link(_opts) do
        GenServer.start_link(__MODULE__, [])
    end

    @impl true
    def init(_) do
        Process.send_after(self(), :start_workers, 1000)
        {:ok, %{}}
    end

    @impl true
    def handle_info(:start_workers, state) do
        Horde.DynamicSupervisor.start_child(
            :cluster_processes_supervisor,
            %{
                id: Dero.Supervisor,
                start: {Dero.Supervisor, :start_link, [[]]},
                restart: :transient
            }
        )
        {:noreply, state}
    end
end
