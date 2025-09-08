defmodule KoombeaScraper.Scraper do
  @moduledoc """
  The Scraper context.
  """

  import Ecto.Query, warn: false
  alias KoombeaScraper.Repo

  alias KoombeaScraper.Scraper.Page

  def list_pages do
    Repo.all(Page)
  end

  def get_page!(id), do: Repo.get!(Page, id)

  def create_page(attrs \\ %{}) do
    %Page{}
    |> Page.changeset(attrs)
    |> Repo.insert()
  end

  def update_page(%Page{} = page, attrs) do
    page
    |> Page.changeset(attrs)
    |> Repo.update()
  end

  def delete_page(%Page{} = page) do
    Repo.delete(page)
  end

  alias KoombeaScraper.Scraper.Link

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