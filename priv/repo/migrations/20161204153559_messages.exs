defmodule Webchat.Repo.Migrations.Chat do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :timestamp, :integer
      add :from, :string, null: false
      add :message, :string
      add :long_msg, :integer
    end
  end
end
