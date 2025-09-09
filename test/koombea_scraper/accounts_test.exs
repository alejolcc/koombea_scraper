defmodule KoombeaScraper.AccountsTest do
  use KoombeaScraper.DataCase, async: true

  alias KoombeaScraper.Accounts
  alias KoombeaScraper.Accounts.User

  import KoombeaScraper.AccountsFixtures

  describe "register_user/1" do
    @valid_attrs %{
      email: "test@example.com",
      password: "valid_password_123",
      username: "test",
      password_confirmation: "valid_password_123"
    }
    @invalid_attrs %{email: "invalid-email", password: "short"}

    test "with valid data, creates a user" do
      assert {:ok, %User{} = user} = Accounts.register_user(@valid_attrs)
      assert user.email == "test@example.com"
      # The password should be hashed and not stored in plain text.
      assert user.hashed_password != "valid_password_123"
      assert user.username == "test"
      assert is_binary(user.hashed_password)
    end

    test "with invalid data, returns an error changeset" do
      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.register_user(@invalid_attrs)
      # Check if the changeset is marked as invalid
      refute changeset.valid?
    end

    test "with a duplicate email, returns an error changeset" do
      # Create an initial user
      {:ok, _user} = Accounts.register_user(@valid_attrs)
      # Attempt to create another user with the same email
      assert {:error, %Ecto.Changeset{}} = Accounts.register_user(@valid_attrs)
    end
  end

  describe "get_user/1" do
    test "when the user exists, returns the user" do
      user = user_fixture()
      assert {:ok, found_user} = Accounts.get_user(user.id)
      assert found_user.id == user.id
    end

    test "when the user does not exist, returns an error" do
      # Use a random UUID that is highly unlikely to exist
      non_existent_id = 987_987
      assert Accounts.get_user(non_existent_id) == {:error, :not_found}
    end
  end

  describe "get_user_by_email_and_password/2" do
    setup do
      # This password will be used for successful authentication tests
      password = "my-real-password"

      user =
        user_fixture(%{
          email: "auth.test@example.com",
          password: password,
          password_confirmation: password
        })

      %{user: user, password: password}
    end

    test "with a valid email and password, returns the user", %{user: user, password: password} do
      assert {:ok, found_user} = Accounts.get_user_by_email_and_password(user.email, password)
      assert found_user.id == user.id
    end

    test "with a valid email but an incorrect password, returns an error", %{user: user} do
      wrong_password = "this-is-wrong"

      assert Accounts.get_user_by_email_and_password(user.email, wrong_password) ==
               {:error, :unauthorized}
    end

    test "with a non-existent email, returns an error", %{password: password} do
      non_existent_email = "not.found@example.com"

      assert Accounts.get_user_by_email_and_password(non_existent_email, password) ==
               {:error, :unauthorized}
    end
  end
end
