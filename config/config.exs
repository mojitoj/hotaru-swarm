# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :hotaru_swarm,
  ecto_repos: [HotaruSwarm.Repo]

# Configures the endpoint
config :hotaru_swarm, HotaruSwarmWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "5AdvFMhhd3V5XQR386I3cPbvfRf7PJDsMR0jBq645ErQHo7oc4G6wrIH5+X417LX",
  render_errors: [view: HotaruSwarmWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: HotaruSwarm.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :mime, :types, %{
  "application/fhir+ndjson" => ["ndjson"],
  "application/fhir+json" => ["json"]
}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
