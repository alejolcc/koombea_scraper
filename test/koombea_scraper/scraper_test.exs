defmodule KoombeaScraper.ScraperTest do
  use KoombeaScraper.DataCase, async: false

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

    test "create_page_from_url/2 creates a page", %{user: user} do
      url = "https://example.com"
      assert {:ok, %Page{} = page} = Scraper.create_page_from_url(url, user.id)
      assert page.url == url
      assert page.user_id == user.id
      assert page.status == :in_progress
    end

    test "create_page_from_url/2 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scraper.create_page_from_url(nil, nil)
    end

    test "create_page_from_url/2 with invalid URL returns error", %{user: user} do
      url = "invalid-url"
      assert {:error, %Ecto.Changeset{} = ch} = Scraper.create_page_from_url(url, user.id)
      assert errors_on(ch).url == ["is not a valid URL"]
    end

    test "multiples users can create pages with the same URL" do
      user1 = user_fixture(%{email: "user1@example.com"})
      user2 = user_fixture(%{email: "user2@example.com"})

      {:ok, page1} = Scraper.create_page_from_url("https://example.com", user1.id)
      {:ok, page2} = Scraper.create_page_from_url("https://example.com", user2.id)

      assert page1.url == "https://example.com"
      assert page2.url == "https://example.com"
      assert page1.user_id != page2.user_id
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

  describe "pagination" do
    setup do
      user = user_fixture()

      for _ <- 1..15 do
        page_fixture(user)
      end

      page = page_fixture(user)

      for i <- 1..15 do
        link_fixture(page, %{name: "Link #{i}"})
      end

      %{user: user, page: page}
    end

    test "list_user_pages_with_link_count/2 paginates pages", %{user: user} do
      # Total pages
      assert Scraper.count_user_pages(user) == 16

      # First page
      pages_with_counts = Scraper.list_user_pages_with_link_count(user, page: 1, per_page: 10)
      assert length(pages_with_counts) == 10

      # Second page
      pages_with_counts = Scraper.list_user_pages_with_link_count(user, page: 2, per_page: 10)
      assert length(pages_with_counts) == 6
    end

    test "list_page_links/2 paginates links", %{page: page} do
      # Total links
      assert Scraper.calculate_total_links(page) == 15

      # First page
      links = Scraper.list_page_links(page, page: 1, per_page: 10)
      assert length(links) == 10

      # Second page
      links = Scraper.list_page_links(page, page: 2, per_page: 10)
      assert length(links) == 5
    end
  end
end
