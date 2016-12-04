# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :webchat, Webchat.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "webchat_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"


# General application configuration
config :webchat,
  ecto_repos: [Webchat.Repo]

# Configures the endpoint
config :webchat, Webchat.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "eWeBEKWNYMrx3BM5Rh6EHpIGrnApWz09ScaJZEkOo0B8WWnLbN9d4wqxvcjBzO/S",
  render_errors: [view: Webchat.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Webchat.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
