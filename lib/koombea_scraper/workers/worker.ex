defmodule KoombeaScraper.Workers.Worker do
  use GenServer

  alias KoombeaScraper.Scraper
  alias KoombeaScraper.Client

  def start_link(page) do
    GenServer.start_link(__MODULE__, page)
  end

  @impl true
  def init(page) do
    {:ok, page, {:continue, :scrape}}
  end

  @impl true
  def handle_continue(:scrape, page) do
    case Client.scrape(page.url) do
      {:ok, %{title: title, links: links}} ->
        {:ok, updated_page} = Scraper.add_links_and_update_page(page, links, %{title: title})
        link_count = Scraper.calculate_total_links(updated_page)
        Scraper.notify({:page_updated, :ok, %{page: updated_page, link_count: link_count}})

      {:error, _reason} ->
        {:ok, updated_page} = Scraper.update_page(page, %{status: :failed})
        Scraper.notify({:page_updated, :failed, %{page: updated_page, link_count: 0}})
    end

    {:stop, :normal, page}
  end
end
