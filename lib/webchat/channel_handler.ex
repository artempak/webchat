defmodule ChannelHandler do
  require Logger

  def process(pid, body) do
    Logger.info "body: #{body}"

    [head | rest] = String.split(body, " ", trim: true)

    case String.to_atom(head) do
      :help -> {:self, prepare_info("-=*** Webchat application, powered by Phoenix ***=-")}
      :setnick when length(rest) > 0 ->
        former = Users.get(pid)
        case Users.setnick(pid, hd(rest)) do
          :true -> {:service, prepare_info("#{former} has changed nickname to #{hd(rest)}")}
          _ -> {:self, prepare_info("Nickname change failed")}
        end
      _ -> {:message, prepare_message(pid, body)}
    end
  end

  def prepare_message(pid, body) do
    message_limit = 20
    nickname = Users.get(pid)
    Logger.info "message from nickname: #{nickname}"
    cond do
      String.length(body) > message_limit ->
        %{from: nickname, timestamp: :os.system_time(:milli_seconds), long_msg: 1, text: String.slice(body, 0..message_limit-1)}
      :true -> %{from: nickname, timestamp: :os.system_time(:milli_seconds), long_msg: 0, text: body}
    end
  end

  def prepare_info(text) do
    %{text: text}
  end

end