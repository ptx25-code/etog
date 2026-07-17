defmodule ElixTogether.Repo do
  use Ecto.Repo,
    otp_app: :elix_together,
    adapter: Ecto.Adapters.Postgres
end
