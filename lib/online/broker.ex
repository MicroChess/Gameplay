defmodule Broker do

    use Broadway
    alias Broadway.Message

    defp rabbit_mq_input(connection), do: {
        BroadwayRabbitMQ.Producer,
        queue: "game_creation_events",
        on_success: :ack,
        on_failure: :reject,
        declare: [ durable: true ],
        connection: connection
    }

    def start_link([dispatcher_concurrency: dc, consumer_concurrency: cc, connection: connection]) do
        Broadway.start_link(
            __MODULE__,
            name: __MODULE__,
            processors: [ default: [ concurrency: dc ] ],
            producer: [ module: rabbit_mq_input(connection), concurrency: cc ]
        )
    end

    @impl Broadway
    def handle_message(_processor, %Message{} = msg, _context) do
        payload = Formatting.decode!(msg.data, :text)
        case process(payload) do
            {:ok, _game_id} -> Broadway.Message.configure_ack(msg, on_success: :ack)
            {:error, _reason} -> Broadway.Message.configure_ack(msg, on_failure: :reject)
        end
    end

    def process(%{"type" => "game_creation", "body" => req}) do
        try do
            board    = Encoding.decode_fen(req["start_board_fen"])
            clock    = Clock.new(req["player_max_time"], req["time_increment"])
            players  = Players.new(req["white_player_id"], req["black_player_id"])
            game     = Game.new(clock, players, board)
            {:ok, _} = Persistence.insert(game)
        rescue
            _ in RuntimeError -> {:error, "error creating the game"}
        end
    end

    def process(%{"type" => _, "body" => _}) do
        {:error, :unknown_event_type}
    end
end
