defmodule KoombeaScraper.Workers.Worker do
  use GenServer

  require Logger
  alias KoombeaScraper.Scraper
  alias KoombeaScraper.Client

  def start_link(initial_value \\ 0) do
    GenServer.start_link(__MODULE__, initial_value, name: __MODULE__)
  end

  def init(_init) do
    {:ok, %{}}
  end

  def scrape(pid \\ __MODULE__, page_id) do
    GenServer.cast(pid, {:scrape, page_id})
  end

  def handle_cast({:scrape, page_id}, state) do
    # Re-fetch the page to get the latest data and preloads
    page = Scraper.get_page!(page_id, preloads: [:links])

    with {:ok, %{title: title, links: links}} <- Client.scrape(page.url),
         {:ok, updated_page} <- Scraper.add_links_and_update_page(page, links, %{title: title}) do
      link_count = Scraper.calculate_total_links(updated_page)
      Scraper.notify({:page_updated, :ok, %{page: updated_page, link_count: link_count}})
    else
      {:error, _reason} ->
        {:ok, updated_page} = Scraper.update_page(page, %{status: :failed})
        Scraper.notify({:page_updated, :failed, %{page: updated_page, link_count: 0}})
    end

    {:noreply, state}
  end
end
