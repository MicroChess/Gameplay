defmodule ClusterChess.Main.Router do

    use Plug.Router

    alias Plug.Conn
    alias ClusterChess.Sockets.Matchmaking
    alias ClusterChess.Commons.Validation

    plug :match
    plug :dispatch

    get "/ws/queue", do: authorize_before(conn, upgrade_to_socket(Matchmaking))
    match _, do: send_resp(conn, 404, "Endpoint Not found in #{__MODULE__}")

    def authorize_before(conn, callback) do
        conn = Plug.Conn.fetch_query_params(conn)
        header = Plug.Conn.get_req_header(conn, "authorization") |> List.first()
        token = conn.query_params["token"] || header || "Guest"
        case Validation.validate_token(token) do
            {:ok, claims} -> callback.(conn, claims)
            {:error, reason} -> send_resp(
                conn, 401, Jason.encode!(%{
                    message: "Unauthorized",
                    reason: reason
                })
            )
        end
    end

    def upgrade_to_socket(type) do
        fn conn, claims ->
            Conn.upgrade_adapter(
                conn, :websocket, {type, claims, []}
            )
        end
    end
end
