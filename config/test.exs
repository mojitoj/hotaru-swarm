use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hotaru_swarm, HotaruSwarmWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :hotaru_swarm, HotaruSwarm.Repo,
  username: "postgres",
  password: "postgres",
  database: "hotaru_swarm_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :hotaru_swarm, HotaruSwarm.Bulk.BulkExport,
  fhir_backends: String.split("http://hapi.fhir.org/baseR4,http://hapi.fhir.org/R", ","),
  exportable_fhir_resources: String.split("Patient,MedicationRequest", ",")
