defmodule Webchat.PageController do
  use Webchat.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

end
