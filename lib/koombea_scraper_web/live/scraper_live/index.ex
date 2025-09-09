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

      <form phx-submit="scrape" class="w-full max-w-sm">
        <div class="flex items-center gap-2">
          <input
            type="text"
            name="query"
            placeholder="Add new page by URL"
            class="input input-bordered w-full"
            phx-debounce="300"
          />
          <button type="submit" class="btn btn-primary">Scrape</button>
        </div>
      </form>

      <.table
        id="pages"
        rows={@pages}
        row_id={fn {page, _count} -> "page-#{page.id}" end}
      >
        <:col :let={{page, _link_count}} label="Title">{page.title}</:col>
        <:col :let={{_page, link_count}} label="Total Links">{link_count}</:col>

        <:action :let={{page, _link_count}}>
          <div>
            <.link navigate={~p"/pages/#{page.id}"}>Show</.link>
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
    if connected?(socket) do
      Scraper.subscribe()
    end

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

    socket = push_patch(socket, to: ~p"/pages")
    {:noreply, socket}
  end

  @impl true
  def handle_event("scrape", %{"query" => url}, socket) do
    # TODO: This will triger the task to scrape the page and store links
    user_id = socket.assigns.current_user.id
    start_scrpaing(url, user_id)

    socket = push_patch(socket, to: ~p"/pages")
    {:noreply, socket}
  end

  # Here we can handle the incoming message and update on the list just the
  # changed item to avoid the extra query. But for simplicity, I will just reload the whole list.
  @impl true
  def handle_info({:page_updated, status, _page}, socket) do
    socket =
      if status == :ok do
        put_flash(socket, :info, "Successfully scraped the page.")
      else
        put_flash(socket, :error, "Scraping failed.")
      end

    socket = push_patch(socket, to: ~p"/pages")
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

  # This function will start the scraping task
  # For now, it's just a placeholder
  defp start_scrpaing(url, user_id) do
    Scraper.create_page_from_url(url, user_id)
  end
end
