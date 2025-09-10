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
            <%= for link <- @links do %>
              <li class="px-4 py-2 border-b border-gray-200">
                <.link_row link={link} />
              </li>
            <% end %>
          </ul>

          <div class="flex justify-center my-4">
            <.pagination_links page_num={@page_num} total_pages={@total_pages} page={@page} />
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    page = Scraper.get_page!(id)

    {:ok,
     socket
     |> assign(:page_title, "Show Page")
     |> assign(:page, page)
     |> assign(:links, [])
     |> assign(:page_num, 1)
     |> assign(:per_page, 10)
     |> assign(:total_pages, 0)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    page = socket.assigns.page
    page_num = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "#{socket.assigns.per_page}")

    links = Scraper.list_page_links(page, page: page_num, per_page: per_page)
    total_pages = ceil(Scraper.calculate_total_links(page) / per_page)

    socket =
      socket
      |> assign(:links, links)
      |> assign(:page_num, page_num)
      |> assign(:total_pages, total_pages)

    {:noreply, socket}
  end

  defp link_row(assigns) do
    ~H"""
    <div class="grid grid-cols-2 gap-2">
      <div>{@link.name}</div>
      <div>{@link.url}</div>
    </div>
    """
  end

  defp pagination_links(assigns) do
    ~H"""
    <div class="join">
      <%= if @page_num > 1 do %>
        <.link class="join-item btn" patch={~p"/pages/#{@page}?page=#{@page_num - 1}"}>«</.link>
      <% end %>

      <%= for i <- 1..@total_pages//1 do %>
        <.link
          class={"join-item btn #{if i == @page_num, do: "btn-active"}"}
          patch={~p"/pages/#{@page}?page=#{i}"}
        >
          {i}
        </.link>
      <% end %>

      <%= if @page_num < @total_pages do %>
        <.link class="join-item btn" patch={~p"/pages/#{@page}?page=#{@page_num + 1}"}>»</.link>
      <% end %>
    </div>
    """
  end
end
