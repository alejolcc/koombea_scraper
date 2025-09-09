defmodule KoombeaScraperWeb.ScraperLiveTest do
  use KoombeaScraperWeb.ConnCase

  import Phoenix.LiveViewTest

  import KoombeaScraper.AccountsFixtures
  import KoombeaScraper.PageFixtures

  defp create_page(_) do
    user = user_fixture()
    page = page_fixture(user)

    %{page: page, user: user}
  end

  describe "Index" do
    setup [:create_page]

    test "lists all pages", %{conn: conn, page: page, user: user} do
      {:ok, _index_live, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/pages")

      assert html =~ "Listing Pages"
      assert html =~ page.title
    end

    test "deletes page in listing", %{conn: conn, page: page, user: user} do
      {:ok, index_live, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/pages")

      assert index_live |> element("#page-#{page.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#page-#{page.id}")
    end

    test "adds new page", %{conn: conn, user: user} do
      {:ok, index_live, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/pages")

      assert index_live
             |> form("form", %{query: "https://elixir-lang.org"})
             |> render_submit()

      assert index_live |> element("table") |> render() =~ "Scraping..."
    end
  end

  describe "Show" do
    setup [:create_page]

    test "displays page", %{conn: conn, page: page, user: user} do
      {:ok, _show_live, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/pages/#{page}")

      assert html =~ "Show Page"
      assert html =~ page.title
    end
  end
end
