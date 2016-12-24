defmodule Users do
    require Logger

    def init do
      Logger.info "Users init"
      case :ets.info(:users) do
        :undefined -> :ets.new(:users, [:set, :public, :named_table])
        _ -> :ok
      end
#      :ets.new(:users, [:set, :public, :named_table])
    end

    def add(pid, nickname) do
      Logger.info "Cache add entry"
      :ets.insert(:users, {inspect(pid), nickname})
    end

    def get(pid) do
      Logger.info "Cache get entry"
      case :ets.lookup(:users, pid) do
        [{pid, nickname}] -> nickname
        _ -> String.replace_leading(inspect(pid), "#PID", "Guest")
      end
    end

    def register(pid) do
      Logger.info "Registering user: #{inspect(pid)}"

      nickname = String.replace_prefix(pid, "#PID", "Guest")
      Logger.info "nickname: #{nickname}"
      :ets.insert(:users, {pid, nickname})
    end

    def is_taken(nickname) do
      result = :ets.match(:users, {:"$1", nickname})
      cond do
        length(result) > 0 -> :true
        :ok -> :false
      end
    end

    def setnick(pid, nickname) do
      cond do
        is_taken(nickname) -> :false
        :ok -> :ets.insert(:users, {pid, nickname})
      end
    end

end