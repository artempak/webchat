defmodule Message do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]
  require Logger

  schema "messages" do
    field :timestamp, :integer
    field :from, :string
    field :message, :string
    field :long_msg, :integer
  end

  @required_fields ~w(timestamp from message long_msg)
  @optional_fields ~w()

  def changeset(message, params \\ :empty) do
    message
    |> cast(params, @required_fields, @optional_fields)
  end

  def history() do
    query = from m in Message,
        select: m, limit: 10, order_by: [desc: m.timestamp]
    Webchat.Repo.all(query)
  end

  def persist(bundle) do
    case Webchat.Repo.insert(changeset(%Message{}, bundle)) do
      {:ok, _} -> :ok
      {:error, _} -> Logger.error "Error saving message", :error
    end
  end
end