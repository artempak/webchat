defmodule Webchat.RoomChannel do
  use Phoenix.Channel
  require Logger

  :ets.new(:user_cache, [:set, :public, :named_table])

  def join("room:lobby", message, socket) do
    pid = inspect(socket.channel_pid)
    Logger.info "New user joined chat room: #{pid}"


    send(self, {:register, message})

    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    pid = inspect(socket.channel_pid)
#    {_, nickname} = :ets.lookup(:user_cache, pid)
    Logger.info "handle_in->Payload: #{inspect(body)}"
#    Logger.info "Nickname: #{nickname}"
    broadcast! socket, "new_msg", %{body: body}
    {:noreply, socket}
  end

#  intercept ["new_msg"]
  def handle_out("new_msg", payload, socket) do
    Logger.info "handle_out->Payload: #{inspect(payload)}"
#    push socket, "new_msg", payload
    {:noreply, socket}
  end

  def handle_info({:register, msg}, socket) do
    Logger.info "handle_info register"
#    broadcast! socket, "user:entered", %{user: msg["user"]}
#    push socket, "join", %{status: "connected"}
    {:noreply, socket}
  end
end