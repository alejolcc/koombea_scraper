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

      <div class="mt-32">
        <div class="px-4 sm:px-8 max-w-5xl m-auto">
          <ul class="border border-gray-200 rounded overflow-hidden shadow-md">
            <%= for link <- @page.links do %>
              <li class="px-4 py-2 border-b border-gray-200">
                <.link_row link={link} />
              </li>
            <% end %>
          </ul>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Page")
     |> assign(:page, Scraper.get_page!(id, preloads: [:links]))}
  end

  defp link_row(assigns) do
    ~H"""
    <div class="grid grid-cols-2 gap-2">
      <div>{@link.name}</div>
      <div>{@link.url}</div>
    </div>
    """
  end
end
