defmodule ProfanityFilter do

  @profane_words ["shit", "fuck", "чёрт"]

  def init() do
    :random.seed(:os.timestamp)
  end

  def filter(pid, message) do
    words = String.split(message, [" ", ",", ".", ";", ":"], trim: true)

    case check_words(words) do
      {:profane, word} -> if 0.1 >= :random.uniform, do: :kick, else: :pass
      _ -> :pass
    end
  end

  def check_words([]) do
    {:ok, ""}
  end

  def check_words([word|rest]) do
    cond do
      word in @profane_words -> {:profane, word}
      :true -> check_words(rest)
    end
  end
end