defmodule Router do

    use Plug.Router

    alias Plug.Conn
    alias Socket

    @fen "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

    plug :match
    plug :dispatch

    get "/v1/gameplay/create" do
        white = Map.get(conn.params, "white-player-id", 1)
        black = Map.get(conn.params, "black-player-id", 2)
        incr  = Map.get(conn.params, "time-increment",  5)
        time  = Map.get(conn.params, "player-max-time", 10)
        fen   = Map.get(conn.params, "start-board-fen", @fen)
        try do
            board = Deserialization.decode_fen(fen)
            game  = Game.new(time, incr, white, black, board)
            {:ok, game_id} = Persinstence.insert(game)
            game_created(conn, game_id)
        rescue
            _ in RuntimeError -> bad_request(conn)
        end
    end

    get "/v1/gameplay/join" do
        conn = Conn.fetch_query_params(conn)
        user_id_header = Conn.get_req_header(conn, "X-User-ID")
        target_game_parameter = conn.params["game-id"]
        case {user_id_header, target_game_parameter} do
            {[user_id], [target_game]} -> upgrade_to_socket(
                conn, Socket, %{
                    user: user_id,
                    game: target_game
                }
            )
            {[], _target_game} -> unauthorized(conn)
            _bad_request -> bad_request(conn)
        end
    end

    match _ do
       send_resp(conn, 404, "Endpoint Not found in #{__MODULE__}")
    end

    defp game_created(conn, game_id) do
        send_resp(conn, 201, Jason.encode!(%{
            message: "Game created: #{game_id}",
            reason: "Connect to: /games/ws/play in order to play"
        }))
    end

    defp bad_request(conn) do
        send_resp(conn, 400, Jason.encode!(%{
            message: "Bad Request",
            reason: "Missing query parameter or invalid headers"
        }))
    end

    defp unauthorized(conn) do
        send_resp(conn, 401, Jason.encode!(%{
            message: "Unauthorized",
            reason: "
                Missing X-User-ID Header (automatically
                added by the authentication layer by
                decoding the JWT/Oauth2.0 token, either
                from headers or query parameters)"
        }))
    end

    defp upgrade_to_socket(conn, type, state) do
        weboscket_opts = [compress: true, timeout: 60_000]
        Conn.upgrade_adapter(
            conn, :websocket, {type, state, weboscket_opts}
        )
    end
end
