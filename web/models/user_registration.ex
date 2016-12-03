defmodule Webchat.UserRegistration do
  import Plug.Conn
  require Logger

  def init(default), do: default

  def call(%Plug.Conn{params: %{"user_token" => token}} = conn, _default) do
    Logger.info "user token: #{inspect(token)}"
    assign(conn, :token, token)
  end
  
end