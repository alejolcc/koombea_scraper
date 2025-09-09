defmodule KoombeaScraper.PageFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `KoombeaScraper.Scraper` context.
  """
  alias KoombeaScraper.Scraper

  def page_fixture(user, attrs \\ %{}) do
    {:ok, page} =
      attrs
      |> Enum.into(%{
        title: "some title",
        url: "https://elixir-lang-#{System.unique_integer()}.org/",
        user_id: user.id
      })
      |> Scraper.create_page()

    page
  end
end
