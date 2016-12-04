defmodule ChannelHandler do
  use Phoenix.Channel
  require Logger

  def process(pid, body) do
    Logger.info "body: #{body}"

    case ProfanityFilter.filter(pid, body) do
      :pass ->
        [head | rest] = String.split(body, " ", trim: true)

        case String.to_atom(head) do
          :help -> {:self, prepare_info("-=*** Webchat application, powered by Phoenix ***=-")}
          :setnick when length(rest) > 0 ->
            former = Users.get(pid)
            case Users.setnick(pid, hd(rest)) do
              :true -> {:service, prepare_info("#{former} has changed nickname to #{hd(rest)}")}
              _ -> {:self, prepare_info("Nickname change failed")}
            end
          :setnick -> {:self, prepare_info("Argument error")}
          _ -> {:message, persist_message(pid, body)}
        end
      _ -> {:kick, %{kick: :true, message: "You have been kicked"}}
    end
  end

  def prepare_info(text) do
    %{message: text}
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