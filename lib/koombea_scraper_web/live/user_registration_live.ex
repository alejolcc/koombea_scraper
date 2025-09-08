defmodule KoombeaScraperWeb.UserRegistrationLive do
  use KoombeaScraperWeb, :live_view

  alias KoombeaScraper.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header>
        Register for an account
        <:subtitle>
          Already registered?
          <.link navigate={~p"/users/log_in"} class="font-semibold text-brand">
            Sign in
          </.link>
          to your account.
        </:subtitle>
      </.header>

      <.form for={@form} id="registration_form" phx-submit="save">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:usernmae]} label="Username" required />
        <.input field={@form[:password]} type="password" label="Password" required />
        <.input
          field={@form[:password_confirmation]}
          type="password"
          label="Confirm Password"
          required
        />

        <.button phx-disable-with="Creating account..." class="w-full">
          Create an account
        </.button>
      </.form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User #{user.email} created successfully.")
         |> redirect(to: ~p"/")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
