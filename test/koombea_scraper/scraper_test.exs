defmodule KoombeaScraper.ScraperTest do
  use KoombeaScraper.DataCase, async: true

  alias KoombeaScraper.Scraper
  alias KoombeaScraper.Scraper.{Page, Link}

  import KoombeaScraper.AccountsFixtures
  import KoombeaScraper.LinkFixtures
  import KoombeaScraper.PageFixtures

  setup do
    user = user_fixture()
    page = page_fixture(user)
    %{user: user, page: page}
  end

  describe "pages" do
    @valid_attrs %{title: "Koombea", url: "https://koombea.com"}
    @update_attrs %{title: "Koombea Inc.", url: "https://www.koombea.com"}
    @invalid_attrs %{title: nil, url: nil}

    test "list_pages/0 returns all pages", %{page: page} do
      assert Scraper.list_pages() == [page]
    end

    test "get_page!/1 returns the page with given id", %{page: page} do
      assert Scraper.get_page!(page.id) == page
    end

    test "get_page!/1 raises if id is not found" do
      assert_raise Ecto.NoResultsError, fn -> Scraper.get_page!(-1) end
    end

    test "create_page/1 with valid data creates a page", %{user: user} do
      valid_attrs_with_user = Map.put(@valid_attrs, :user_id, user.id)

      assert {:ok, %Page{} = page} = Scraper.create_page(valid_attrs_with_user)
      assert page.title == "Koombea"
      assert page.url == "https://koombea.com"
      assert page.user_id == user.id
    end

    test "create_page/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scraper.create_page(@invalid_attrs)
    end

    test "create_page/1 with a non-unique URL returns error changeset", %{user: user} do
      # Insert the first page
      page_fixture(user, @valid_attrs)

      # Try to insert a second page with the same URL
      valid_attrs_with_user = Map.put(@valid_attrs, :user_id, user.id)
      assert {:error, changeset} = Scraper.create_page(valid_attrs_with_user)
      assert "has already been taken" in errors_on(changeset).url
    end

    test "update_page/2 with valid data updates the page", %{user: user} do
      page = page_fixture(user)
      assert {:ok, %Page{} = updated_page} = Scraper.update_page(page, @update_attrs)
      assert updated_page.title == "Koombea Inc."
      assert updated_page.url == "https://www.koombea.com"
    end

    test "update_page/2 with invalid data returns error changeset", %{user: user} do
      page = page_fixture(user)
      assert {:error, %Ecto.Changeset{}} = Scraper.update_page(page, @invalid_attrs)
      # Ensure the original page was not changed
      assert page == Scraper.get_page!(page.id)
    end

    test "delete_page/1 deletes the page", %{user: user} do
      page = page_fixture(user)
      assert {:ok, %Page{}} = Scraper.delete_page(page)
      assert_raise Ecto.NoResultsError, fn -> Scraper.get_page!(page.id) end
    end
  end

  describe "links" do
    @valid_attrs %{name: "Phoenix Framework", url: "https://phoenixframework.org"}
    @update_attrs %{name: "Elixir Lang", url: "https://elixir-lang.org"}
    @invalid_attrs %{name: nil, url: nil}

    test "list_links/0 returns all links", %{page: page} do
      link = link_fixture(page)
      assert Scraper.list_links() == [link]
    end

    test "get_link!/1 returns the link with given id", %{page: page} do
      link = link_fixture(page)
      assert Scraper.get_link!(link.id) == link
    end

    test "create_link/1 with valid data creates a link", %{page: page} do
      valid_attrs_with_page = Map.put(@valid_attrs, :page_id, page.id)

      assert {:ok, %Link{} = link} = Scraper.create_link(valid_attrs_with_page)
      assert link.name == "Phoenix Framework"
      assert link.url == "https://phoenixframework.org"
      assert link.page_id == page.id
    end

    test "create_link/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scraper.create_link(@invalid_attrs)
    end

    test "update_link/2 with valid data updates the link", %{page: page} do
      link = link_fixture(page)
      assert {:ok, %Link{} = updated_link} = Scraper.update_link(link, @update_attrs)
      assert updated_link.name == "Elixir Lang"
      assert updated_link.url == "https://elixir-lang.org"
    end

    test "update_link/2 with invalid data returns error changeset", %{page: page} do
      link = link_fixture(page)
      assert {:error, %Ecto.Changeset{}} = Scraper.update_link(link, @invalid_attrs)
      assert link == Scraper.get_link!(link.id)
    end

    test "delete_link/1 deletes the link", %{page: page} do
      link = link_fixture(page)
      assert {:ok, %Link{}} = Scraper.delete_link(link)
      assert_raise Ecto.NoResultsError, fn -> Scraper.get_link!(link.id) end
    end
  end
end
