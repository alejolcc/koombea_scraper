defmodule KoombeaScraper.Scraper.Link do
  use Ecto.Schema
  import Ecto.Changeset

  schema "links" do
    field :name, :string
    field :url, :string
    belongs_to :page, KoombeaScraper.Scraper.Page

    timestamps()
  end

  @doc false
  def changeset(link, attrs) do
    link
    |> cast(attrs, [:name, :url, :page_id])
    |> validate_required([:name, :url, :page_id])
  end
end
