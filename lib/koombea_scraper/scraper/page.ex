defmodule KoombeaScraper.Scraper.Page do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pages" do
    field :title, :string
    field :url, :string
    field :status, Ecto.Enum, values: [:in_progress, :finish, :failed]
    belongs_to :user, KoombeaScraper.Accounts.User
    has_many :links, KoombeaScraper.Scraper.Link

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:title, :url, :user_id, :status])
    |> validate_required([:title, :url, :user_id])
    |> validate_url_format(:url)
    |> unique_constraint(:url, name: :pages_url_index)
  end

  defp validate_url_format(changeset, field) do
    # Get the value of the field from the changeset
    url = get_field(changeset, field)

    # Only run the validation if the URL is not nil
    if url do
      case URI.parse(url) do
        # A valid URI must have a host (e.g., "google.com") and a valid scheme
        %URI{scheme: scheme, host: host} when scheme in ["http", "https"] and not is_nil(host) ->
          changeset

        _ ->
          add_error(changeset, field, "is not a valid URL")
      end
    else
      # If the field is nil, let `validate_required` handle the error.
      changeset
    end
  end
end
