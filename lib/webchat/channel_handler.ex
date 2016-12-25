defmodule ChannelHandler do
  use Phoenix.Channel
  require Logger

  @message_limit 20

  def process(pid, body) do

    case ChatCommand.evaluate(body) do
      {:message, message} ->
        case ProfanityFilter.filter(body) do
          {:pass, message} ->
            bundle = prepare_message(pid, message)
#            persist_message(pid, bundle)
            {:message, bundle}
          {:filter, message} ->
            bundle = prepare_message(pid, message)
#            persist_message(pid, body)
            {:message, bundle}
          {:kick, message} ->
            {:kick, %{kick: :true, message: message}}
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

  def persist_message(pid, body) do
    message_limit = 20
    nickname = Users.get(pid)
    Logger.info "message from nickname: #{nickname}"

    {msg, is_long} = if String.length(body) > message_limit, do: {String.slice(body, 0..message_limit-1), 1}, else: {body, 0}

    json = %{from: nickname, timestamp: :os.system_time(:seconds), long_msg: is_long, message: msg}

    changeset = Message.changeset(%Message{}, json)

    case Webchat.Repo.insert(changeset) do
      {:ok, model}        -> json
      {:error, changeset} -> json
    end
#    json
  end

  def push_history(socket) do
    Logger.info "push history PID=#{inspect(self())}"
    history = Message.history()
    cond do
      length(history) == 0 -> :ok
      :true -> push_single_message(socket, :lists.reverse(history))
    end
  end

  def push_single_message(socket, []) do
    :ok
  end

  def push_single_message(socket, [msg|rest]) do
    %{from: nickname, long_msg: long_msg, message: message, timestamp: timestamp} = msg
    push socket, "new_msg", %{from: nickname, long_msg: long_msg, message: message, timestamp: timestamp}
    push_single_message(socket, rest)
  end
end