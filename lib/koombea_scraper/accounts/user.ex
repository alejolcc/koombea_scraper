defmodule KoombeaScraper.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :username, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string
    field :confirmed_at, :naive_datetime

    has_many :pages, KoombeaScraper.Scraper.Page

    timestamps()
  end

  @doc """
  A user changeset for registration.

  It is important to always cast passwords towards the changeset
  and never the schema itself. This ensures our password hash
  does not get leaked in logs and other places.
  """
  def registration_changeset(user, attrs, _opts \\ []) do
    user
    |> cast(attrs, [:email, :password, :username])
    |> validate_email()
    |> validate_password()
    |> validate_confirmation(:password, message: "Passwords do not match", required: true)
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, KoombeaScraper.Repo)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset, opts \\ []) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 72)
    |> maybe_hash_password(opts)
  end

  # For simplicity, we are not enforcing complex password rules here.
  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # Changeset.validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
      # |> Changeset.validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
      # |> Changeset.validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or special character")
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end
end
