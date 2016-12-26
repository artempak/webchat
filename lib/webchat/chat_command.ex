defmodule ChatCommand do

  @commands ["help", "setnick"]

  def evaluate(pid, text) do
    [head | rest] = String.split(text, " ", trim: true)

    cond do
      not head in @commands -> {:message}
      head == <<"help">> -> ChatCommand.Help.handle(pid, rest)
      head == <<"setnick">> -> ChatCommand.Setnick.handle(pid, rest)
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