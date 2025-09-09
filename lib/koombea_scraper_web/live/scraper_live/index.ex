defmodule KoombeaScraperWeb.ScraperLive.Index do
  use KoombeaScraperWeb, :live_view

  alias KoombeaScraper.Scraper
  alias KoombeaScraper.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Pages
      </.header>

      <form phx-change="search" class="w-full">
        <input
          type="text"
          name="query"
          placeholder="Add new page by URL"
          class="input input-bordered w-full max-w-xs"
          phx-debounce="300"
        />
      </form>

      <.table
        id="pages"
        rows={@pages}
        row_id={fn {page, _count} -> "page-#{page.id}" end}
      >
        <:col :let={{page, _link_count}} label="Title">{page.title}</:col>
        <:col :let={{_page, link_count}} label="Total Links">{link_count}</:col>

        <:action :let={{page, _link_count}}>
          <div class="sr-only">
            <.link navigate={~p"/pages/#{page}"}>Show</.link>
          </div>
        </:action>
        <:action :let={{page, _link_count}}>
          <.link
            phx-click={JS.push("delete", value: %{id: page.id}) |> hide("#page-#{page.id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_user(session)
     |> assign(:page_title, "Listing Pages")
     |> assign(:pages, [])}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    user = socket.assigns.current_user
    pages_with_counts = Scraper.list_user_pages_with_link_count(user)

    socket = assign(socket, :pages, pages_with_counts)

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    page = Scraper.get_page!(id)
    {:ok, _} = Scraper.delete_page(page)

    {:noreply, stream_delete(socket, :pages, page)}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do

    IO.inspect query, label: "Search query"
    {:noreply, socket}
  end

  defp assign_user(socket, session) do
    if user_id = session["user_id"] do
      case Accounts.get_user(user_id) do
        {:error, _} -> socket
        {:ok, user} -> assign(socket, :current_user, user)
      end
    else
      socket
    end
  end

  defp list_pages() do
    Scraper.list_pages()
  end
end
