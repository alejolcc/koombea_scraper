defmodule KoombeaScraper.Scraper do
  @moduledoc """
  The Scraper context.
  """

  import Ecto.Query, warn: false
  alias KoombeaScraper.Repo
  alias KoombeaScraper.Client
  alias KoombeaScraper.Scraper.Page
  alias KoombeaScraper.Scraper.Link
  alias KoombeaScraper.Accounts.User

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

  def get_page!(id, opts \\ []) do
    preloads = Keyword.get(opts, :preloads, [])

    Repo.get(Page, id)
    |> Repo.preload(preloads)
  end

  def create_page(attrs \\ %{}) do
    %Page{}
    |> Page.changeset(attrs)
    |> Repo.insert()
  end

  def create_page_from_url(url, user_id) do
    case Client.scrape(url) do
      {:ok, %{title: title, links: links}} ->
        Repo.transaction(fn ->
          with {:ok, page} <- create_page(%{title: title, url: url, user_id: user_id}) do
            add_links_to_page(page, links)
            {:ok, page}
          end
        end)

      {:error, reason} ->
        {:error, reason}
    end
  end

  def add_links_to_page(%Page{} = page, links) when is_list(links) do
    links =
      Enum.map(links, fn link ->
        Map.merge(link, %{
          page_id: page.id
        })
      end)

    Repo.insert_all(Link, links)
  end

  def update_page(%Page{} = page, attrs) do
    page
    |> Page.changeset(attrs)
    |> Repo.update()
  end

  def delete_page(%Page{} = page) do
    Repo.delete(page)
  end

  def calculate_total_links(%Page{} = page) do
    Repo.aggregate(from(l in Link, where: l.page_id == ^page.id), :count, :id)
  end

  def list_links do
    Repo.all(Link)
  end

  def get_link!(id), do: Repo.get!(Link, id)

  def create_link(attrs \\ %{}) do
    %Link{}
    |> Link.changeset(attrs)
    |> Repo.insert()
  end

  def update_link(%Link{} = link, attrs) do
    link
    |> Link.changeset(attrs)
    |> Repo.update()
  end

  def delete_link(%Link{} = link) do
    Repo.delete(link)
  end
end
