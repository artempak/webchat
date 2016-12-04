defmodule Webchat.RoomChannel do
  use Phoenix.Channel
  require Logger

  def join("room:lobby", message, socket) do
    pid = inspect(socket.channel_pid)
    Logger.info "New user joined chat room: #{pid} #{:os.system_time(:milli_seconds)}"

    send(self, {:register, message})

    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    pid = inspect(socket.channel_pid)
    case ChannelHandler.process(pid, body) do
      {:message, json} -> broadcast! socket, "new_msg", json
      {:self, json} -> push socket, "self", json
      {:service, json} -> broadcast! socket, "service", json
      {:kick, json} -> push socket, "self", json
    end
    {:noreply, socket}
  end

  def handle_info({:register, msg}, socket) do
    Logger.info "handle_info register"
    pid = inspect(socket.channel_pid)

    Users.register(pid)
    ChannelHandler.push_history(socket)

    {:noreply, socket}
  end
end