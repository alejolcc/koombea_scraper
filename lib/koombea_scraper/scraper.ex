defmodule KoombeaScraper.Scraper do
  @moduledoc """
  The Scraper context.
  """

  require Logger
  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias KoombeaScraper.Repo
  alias KoombeaScraper.Scraper.Page
  alias KoombeaScraper.Scraper.Link
  alias KoombeaScraper.Accounts.User

  alias Phoenix.PubSub

  @pubsub KoombeaScraper.PubSub

  @doc """
  Returns the list of pages.

  ## Examples

      iex> list_pages()
      [%Page{}, ...]

  """
  def list_pages do
    Repo.all(Page)
  end

  @doc """
  Retrieves all pages for a given user, including a count of links for each page.

  Returns a list of tuples in the format `{%KoombeaScraper.Scraper.Page{}, link_count}`.

  ## Examples

      iex> list_user_pages_with_link_count(user)
      [%Page{id: 1, ...}, 5]

  Is used to avoid N+1 query problem when displaying pages with their link counts.
  """
  def list_user_pages_with_link_count(%User{} = user) do
    query =
      from(p in Page,
        where: p.user_id == ^user.id,
        left_join: l in assoc(p, :links),
        group_by: p.id,
        select: {p, count(l.id)}
      )

    Repo.all(query)
  end

  @doc """
  Gets a single page.

  Raises `Ecto.NoResultsError` if the Page with given id does not exist.

  ## Examples

      iex> get_page!(123)
      %Page{}

      iex> get_page!(456)
      ** (Ecto.NoResultsError)

  """
  def get_page!(id, opts \\ []) do
    preloads = Keyword.get(opts, :preloads, [])

    Repo.get!(Page, id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a page.

  ## Examples

      iex> create_page(%{field: value})
      {:ok, %Page{}}

      iex> create_page(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_page(attrs \\ %{}) do
    %Page{}
    |> Page.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a page from a URL and starts the scraping process.
  It will create a page with status `:in_progress` and then
  call the worker to perform the scraping asynchronously.

  ## Examples

      iex> create_page_from_url("https://elixir-lang.org", 1)
      {:ok, %Page{}}

  """
  def create_page_from_url(url, user_id) do
    attrs = %{title: "Scraping...", url: url, user_id: user_id, status: :in_progress}

    case create_page(attrs) do
      {:ok, page} ->
        KoombeaScraper.Workers.Worker.scrape(page.id)
        {:ok, page}

      {:error, changeset} = error ->
        Logger.error("Failed to create page: #{inspect(changeset)}")
        error
    end
  end

  @doc """
  Adds links to a page and updates its status to `:finish`.

  This function is idempotent, so it can be safely retried.

  ## Examples

      iex> add_links_and_update_page(page, [%{name: "Elixir", url: "https://elixir-lang.org"}], %{title: "Elixir"})
      {:ok, %Page{}}

  """
  def add_links_and_update_page(%Page{} = page, links, attrs) when is_list(links) do
    links =
      Enum.map(links, fn link ->
        Map.merge(link, %{
          page_id: page.id
        })
      end)

    page_attrs = Map.merge(attrs, %{status: :finish})
    page_changeset = Page.changeset(page, page_attrs)

    Multi.new()
    |> Multi.update(:page, page_changeset)
    |> Multi.insert_all(:links, Link, links,
      # Because we are calling this from a GenServer we want the operation to be idempotent
      on_conflict: :nothing,
      on_conflict_target: [:page_id, :url, :name]
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{page: updated_page}} ->
        {:ok, updated_page}

      {:error, _operation, reason, _changes} ->
        Logger.error("Failed to add links and update page: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Updates a page.

  ## Examples

      iex> update_page(page, %{field: new_value})
      {:ok, %Page{}}

      iex> update_page(page, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_page(%Page{} = page, attrs) do
    page
    |> Page.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a page.

  ## Examples

      iex> delete_page(page)
      {:ok, %Page{}}

      iex> delete_page(page)
      {:error, %Ecto.Changeset{}}

  """
  def delete_page(%Page{} = page) do
    Repo.delete(page)
  end

  @doc """
  Calculates the total number of links for a page.

  ## Examples

      iex> calculate_total_links(page)
      5

  """
  def calculate_total_links(%Page{} = page) do
    Repo.aggregate(from(l in Link, where: l.page_id == ^page.id), :count, :id)
  end

  @doc """
  Returns the list of links.

  ## Examples

      iex> list_links()
      [%Link{}, ...]

  """
  def list_links do
    Repo.all(Link)
  end

  @doc """
  Gets a single link.

  Raises `Ecto.NoResultsError` if the Link with given id does not exist.

  ## Examples

      iex> get_link!(123)
      %Link{}

      iex> get_link!(456)
      ** (Ecto.NoResultsError)

  """
  def get_link!(id), do: Repo.get!(Link, id)

  @doc """
  Creates a link.

  ## Examples

      iex> create_link(%{field: value})
      {:ok, %Link{}}

      iex> create_link(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_link(attrs \\ %{}) do
    %Link{}
    |> Link.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a link.

  ## Examples

      iex> update_link(link, %{field: new_value})
      {:ok, %Link{}}

      iex> update_link(link, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_link(%Link{} = link, attrs) do
    link
    |> Link.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a link.

  ## Examples

      iex> delete_link(link)
      {:ok, %Link{}}

      iex> delete_link(link)
      {:error, %Ecto.Changeset{}}

  """
  def delete_link(%Link{} = link) do
    Repo.delete(link)
  end

  @doc """
  Subscribes to page update events.
  """
  def subscribe() do
    Phoenix.PubSub.subscribe(@pubsub, "page_update")
  end

  @doc """
  Unsubscribes from page update events.
  """
  def unsubscribe() do
    Phoenix.PubSub.unsubscribe(@pubsub, "page_update")
  end

  @doc """
  Notifies subscribers of a page update event.
  """
  def notify(event) do
    PubSub.broadcast(@pubsub, "page_update", event)
  end
end
