defmodule KoombeaScraper.Scraper.Page do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pages" do
    field :title, :string
    field :url, :string
    field :status, Ecto.Enum, values: [:in_progress, :finish]
    belongs_to :user, KoombeaScraper.Accounts.User
    has_many :links, KoombeaScraper.Scraper.Link

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:title, :url, :user_id, :status])
    |> validate_required([:title, :url, :user_id])
    |> unique_constraint(:url, name: :pages_url_index)
  end
end
