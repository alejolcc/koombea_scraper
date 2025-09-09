defmodule KoombeaScraper.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias KoombeaScraper.Repo

  alias KoombeaScraper.Accounts.User

  def get_user(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def get_user_by_email_and_password(email, password) do
    user = Repo.get_by(User, email: email)

    if user && Bcrypt.verify_pass(password, user.hashed_password) do
      {:ok, user}
    else
      {:error, :unauthorized}
    end
  end

  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end
end
