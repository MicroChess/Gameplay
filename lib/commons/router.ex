defmodule Commons.Router do

    use Plug.Router

    alias Plug.Conn
    alias Match.Socket

    plug :match
    plug :dispatch

    get "/ws/play" do
        conn = Plug.Conn.fetch_query_params(conn)
        user_id_header = Plug.Conn.get_req_header(conn, "X-User-ID")
        target_game_parameter = Plug.Conn.get_req_param(conn, "game-id")
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

    defp bad_request(conn) do
        send_resp(conn, 400, Jason.encode!(%{
            message: "Bad Request",
            reason: "Missing ?game query parameter or invalid headers"
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
