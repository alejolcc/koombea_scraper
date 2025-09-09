defmodule KoombeaScraper.Client do
  @moduledoc """
  A client to scrape a web page and extract its title and links.
  """
  require Logger

  @doc """
  Scrapes a given URL and returns the page title and a list of links.
  """
  def scrape(url) do
    with {:ok, _} <- validate_url(url),
         {:ok, response} <- Req.get(url),
         {:ok, body} <- Floki.parse_document(response.body) do
      title = Floki.find(body, "title") |> Floki.text()

      links =
        Floki.find(body, "a")
        |> Enum.map(fn link ->
          %{
            name: Floki.text(link),
            url: Floki.attribute(link, "href") |> List.first()
          }
        end)

      {:ok, %{title: title, links: links}}
    else
      {:error, reason} ->
        Logger.error("Failed to scrape URL: #{url}")
        {:error, reason}
    end
  end

  defp validate_url(url) do
    case URI.parse(url) do
      %URI{scheme: scheme} when scheme in ["http", "https"] -> {:ok, url}
      _ -> {:error, :invalid_url}
    end
  end
end
