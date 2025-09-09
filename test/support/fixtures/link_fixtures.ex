defmodule KoombeaScraper.LinkFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `KoombeaScraper.Accounts` context.
  """

  alias KoombeaScraper.Scraper

  def link_fixture(page, attrs \\ %{}) do
    {:ok, link} =
      attrs
      |> Enum.into(%{
        name: "Some link name",
        url: "https://example.com/link-#{System.unique_integer([:positive])}",
        page_id: page.id
      })
      |> Scraper.create_link()

    link
  end
end
