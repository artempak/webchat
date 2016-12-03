defmodule Webchat.PageController do
  use Webchat.Web, :controller
  require Logger

  plug :register

  def index(conn, _params) do
    render conn, "index.html"
  end

  defp register(%Plug.Conn{cookies: %{"userId" => userId}} = conn, _) when userId != "" do
    Logger.info "Cookies exist"
    Logger.info "UserId: #{inspect(userId)}"
    conn
  end

  defp register(conn, _) do
    Logger.info "Conn: #{inspect(conn)}"
    Logger.info "Owner: #{inspect(conn.owner)}"
#    assign(conn, :user_id, "UUUUUUU")
#    Logger.info "Conn 2: #{inspect(conn)}"
    conn
  end

end
