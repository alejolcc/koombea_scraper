defmodule KoombeaScraperWeb.UserAuth do
  use KoombeaScraperWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias KoombeaScraper.Accounts

  def on_mount(:mount_current_user, _params, session, socket) do
    {:cont, mount_current_user(socket, session)}
  end

  defp mount_current_user(socket, session) do
    Phoenix.Component.assign_new(socket, :current_user, fn ->
      get_user_from_session(session)
    end)
  end

  def fetch_current_user(conn, _opts) do
    assign(conn, :current_user, get_user_from_session(conn))
  end

  defp get_user_from_session(conn) do
    user_id = get_session(conn, :user_id)
    user_id && Accounts.get_user!(user_id)
  end

  def log_in_user(conn, user) do
    conn
    |> put_session(:user_id, user.id)
    |> redirect(to: ~p"/")
  end

  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> redirect(to: "/users/log_in")
      |> halt()
    end
  end

  def log_out_user(conn) do
    if live_socket_id = get_session(conn, :live_socket_id) do
      KoombeaScraperWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    redirect(conn, to: ~p"/users/log_in")
  end
end
