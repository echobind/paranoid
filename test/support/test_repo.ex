defmodule Paranoid.TestRepo do
  use Ecto.Repo,
  otp_app: :paranoid,
  adapter: Ecto.Adapters.Postgres
end
