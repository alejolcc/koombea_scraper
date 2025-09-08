defmodule KoombeaScraperWeb.PageController do
  use KoombeaScraperWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
