defmodule ChatCommand do
  require Logger

  @commands ["help", "setnick"]

  def init() do
    Users.init()
  end

  def evaluate(text) do
    [head | rest] = String.split(text, " ", trim: true)

    unless head in @commands, do: {:message, text}

    cond do
      head == <<"help">> -> ChatCommand.Help.handle(self(), rest)
      head == <<"setnick">> -> ChatCommand.Setnick.handle(self(), rest)
      :true -> {:self, "Unknown command"}
    end
  end


  defmodule Help do
    defp info() do
      "Simple chat server, powered by Phoenix"
    end

    def handle(_uid, _args) do
      {:self, info}
    end
  end

  defmodule Setnick do
    defp info() do
      "setnick {Nickname}"
    end

    def handle(pid, args) when length(args) == 1 do
      oldnick = Users.get(pid)
      newnick = hd(args)
      Logger.info "handle(#{inspect(pid)}, #{inspect(newnick)})              oldnick = #{inspect(oldnick)}"
      case Users.setnick(pid, newnick) do
        :true -> {:service, "#{oldnick} has changed nickname to #{newnick}"}
        _ -> {:self, "Nickname change failed"}
      end
    end

    def handle(_uid, _args) do
      {:self, info}
    end

  end
end