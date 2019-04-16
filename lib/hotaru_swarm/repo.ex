defmodule HotaruSwarm.Repo do
  use Ecto.Repo,
    otp_app: :hotaru_swarm,
    adapter: Ecto.Adapters.Postgres
end
