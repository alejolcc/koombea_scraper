defmodule KoombeaScraperWeb.ScraperLive.Show do
  use KoombeaScraperWeb, :live_view

  alias KoombeaScraper.Scraper

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page.title}

        <:actions>
          <.button navigate={~p"/pages"}>
            <.icon name="hero-arrow-left" />
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@page.title}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Page")
     |> assign(:page, Scraper.get_page!(id))}
  end
end
