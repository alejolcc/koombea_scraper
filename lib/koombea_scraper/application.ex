defmodule KoombeaScraper.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      KoombeaScraperWeb.Telemetry,
      KoombeaScraper.Repo,
      {DNSCluster, query: Application.get_env(:koombea_scraper, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: KoombeaScraper.PubSub},
      KoombeaScraper.Workers.Worker,
      KoombeaScraperWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: KoombeaScraper.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    KoombeaScraperWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
