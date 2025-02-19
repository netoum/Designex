defmodule PhoenixTailwindV4.Repo do
  use Ecto.Repo,
    otp_app: :phoenix_tailwind_v4,
    adapter: Ecto.Adapters.Postgres
end
