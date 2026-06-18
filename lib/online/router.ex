defmodule Router do

    use Plug.Router

    alias Plug.Conn
    alias Socket

    plug :match
    plug :dispatch

    get "/v1/gameplay/join" do
        conn = Conn.fetch_query_params(conn)
        user_id_header = Conn.get_req_header(conn, "x-user-id")
        target_game_parameter = conn.params["game-id"]
        case {user_id_header, target_game_parameter} do
            {[user_id], target_game} when not is_nil(target_game) -> upgrade_to_socket(
                conn, Socket, %{
                    user: user_id,
                    game: target_game
                }
            )
            {[], _} -> unauthorized(conn)
            _ -> bad_request(conn)
        end
    end

    match _ do
       send_resp(conn, 404, "Endpoint Not found in #{__MODULE__}")
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
