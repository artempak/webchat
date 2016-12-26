defmodule ChannelHandler do
  require Logger

  @message_limit 20

  def process(pid, body) do
    case ChatCommand.evaluate(pid, body) do
      {:message} ->
        case ProfanityFilter.evaluate(body) do
          {:kick, message} ->
            {:kick, %{kick: :true, message: message}}
          {:filter, message} ->
            bundle = prepare_message(pid, message)
            original = prepare_message(pid, body)
            Message.persist(original)
            {:message, bundle}  
          {_, message} ->
            bundle = prepare_message(pid, message)
            Message.persist(bundle)
            {:message, bundle}
        end
      {res, message} -> {res, prepare_info(message)}
    end
  end

  def prepare_info(text) do
    %{message: text}
  end

  def prepare_message(pid, text) do
    nickname = Users.get(pid)
    Logger.info "message from nickname: #{nickname}"

    {msg, is_long} = if String.length(text) > @message_limit, do: {String.slice(text, 0..@message_limit-1), 1}, else: {text, 0}

    %{from: nickname, timestamp: :os.system_time(:seconds), long_msg: is_long, message: msg}
  end

  def push_history(socket) do
    Logger.info "push history PID=#{inspect(self())}"
    history = Message.history()
    cond do
      length(history) == 0 -> :ok
      :true -> push_single_message(socket, :lists.reverse(history))
    end
  end

  defp push_single_message(_socket, []) do
    :ok
  end

  defp push_single_message(socket, [msg | rest]) do
    %{from: nickname, long_msg: long_msg, message: message, timestamp: timestamp} = msg
    Phoenix.Channel.push socket, "new_msg", %{from: nickname, long_msg: long_msg, message: ProfanityFilter.filter(message), timestamp: timestamp}
    push_single_message(socket, rest)
  end
end