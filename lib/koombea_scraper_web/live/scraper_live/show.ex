defmodule KoombeaScraperWeb.ScraperLive.Show do
  use KoombeaScraperWeb, :live_view

  alias KoombeaScraper.Scraper

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Page {@page.id}
        <:subtitle>This is a page record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/pages"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/pages/#{@page}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit page
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
