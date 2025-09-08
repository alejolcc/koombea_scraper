defmodule KoombeaScraperWeb.UserLoginLive do
  use KoombeaScraperWeb, :live_view

  alias KoombeaScraper.Accounts
  alias KoombeaScraperWeb.UserAuth

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header>
        Log in to account
        <:subtitle>
          Don't have an account?
          <.link navigate={~p"/users/register"} class="font-semibold text-brand">
            Sign up
          </.link>
          for a free account.
        </:subtitle>
      </.header>

      <.form for={@form} id="login_form" action={~p"/users/log_in"}>
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <.button phx-disable-with="Signing in..." >
          Sign in <span aria-hidden="true">→</span>
        </.button>
      </.form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
