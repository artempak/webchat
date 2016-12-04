defmodule ChannelHandler do
  require Logger

  def process(pid, body) do
    Logger.info "body: #{inspect(body)}"
    #%{body: body}
    prepare_chat_msg(body)

    {:service, %{text: body}}
  end

  def prepare_chat_msg(body) do
    message_limit = 20
    cond do
      String.length(body) > message_limit ->
        %{type: 0, timestamp: :os.system_time(:milli_seconds), long_msg: 1, text: String.slice(body, 0..message_limit-1)}
      :true -> %{type: 0, timestamp: :os.system_time(:milli_seconds), long_msg: 0, text: body}
    end
  end

  def prepare_service_msg(msg) do
    %{type: 1, timestamp: :os.system_time(:milli_seconds), text: msg}
  end
end