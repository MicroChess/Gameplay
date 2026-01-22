defmodule ClusterChess.Datapack.Default do
    defmacro __using__(_opts) do
        quote do
            @behaviour ClusterChess.Datapack.Behaviour

            @impl ClusterChess.Datapack.Behaviour
            def enforce(data) do
                module = unquote(__MODULE__)
                values = struct(module, data) |> Map.values()
                not_nil? = fn v -> !is_nil(v) end
                if Enum.all?(values, not_nil?),
                    do: {:ok, struct(module, data)},
                    else: {:error, "Invalid datapack"}
            end

            defoverridable enforce: 1
        end
    end
end
