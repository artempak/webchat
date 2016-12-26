defmodule ProfanityFilter do

  @kick_prob 0.1
  @profane_words ["shit", "fuck", "чёрт"]

  def init() do
    :rand.seed(:exs1024)
  end

  def evaluate(message) do
    case check_words(tokenize(message), []) do
      {:profane, filter_acc} ->
        if @kick_prob >= :rand.uniform do 
          {:kick, "You have been kicked!"}
        else
          {:filter, replace_profane_words(message, filter_acc)}
        end
      {:ok, _} -> {:pass, message}
    end
  end

  def filter(message) do
    case check_words(tokenize(message), []) do
      {:profane, filter_acc} -> replace_profane_words(message, filter_acc)
      {:ok, _} -> message
    end
  end

  defp tokenize(message) do
    String.split(message, [" ", ",", ".", ";", ":"], trim: true)
  end

  defp check_words([], []), do: {:ok, []}

  defp check_words([], filter_acc) when length(filter_acc) > 0, do: {:profane, filter_acc}

  defp check_words([word | rest], filter_acc) do
    if String.downcase(word) in @profane_words do
      check_words(rest, [word | filter_acc])
    else
      check_words(rest, filter_acc)
    end
  end
  
  defp replace_profane_words(message, []), do: message

  defp replace_profane_words(message, [word | rest]) do
    replace_profane_words(String.replace(message, word, "*****"), rest)
  end
end