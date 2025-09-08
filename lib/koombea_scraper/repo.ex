defmodule KoombeaScraper.Repo do
  use Ecto.Repo,
    otp_app: :koombea_scraper,
    adapter: Ecto.Adapters.Postgres
end
