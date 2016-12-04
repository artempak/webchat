defmodule Webchat.RoomChannel do
  use Phoenix.Channel
  require Logger

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
#    broadcast! socket, "new_msg", %{body: body}
    #broadcast! socket, "new_msg", ChannelHandler.process(pid, body)
    #broadcast! socket, "service", ChannelHandler.process(pid, body)
    case ChannelHandler.process(pid, body) do
      {:message, json} -> broadcast! socket, "new_msg", json
      {:self, json} -> push socket, "self", json
      {_, json} -> broadcast! socket, "service", json
    end
    {:noreply, socket}
  end

#  intercept ["new_msg"]
#  def handle_out("new_msg", payload, socket) do
#    Logger.info "handle_out->Payload: #{inspect(payload)}"
#    push socket, "new_msg", payload
#    {:noreply, socket}
#  end

  def handle_info({:register, msg}, socket) do
    Logger.info "handle_info register"
    pid = inspect(socket.channel_pid)

    Users.register(pid)
#    broadcast! socket, "user:entered", %{user: msg["user"]}
#    push socket, "join", %{status: "connected"}
    {:noreply, socket}
  end
end