defmodule KoombeaScraper.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `KoombeaScraper.Accounts` context.
  """

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some-email-#{System.unique_integer()}@example.com",
        username: "some username",
        password: "some_password",
        password_confirmation: "some_password"
      })
      |> KoombeaScraper.Accounts.register_user()

    user
  end
end
