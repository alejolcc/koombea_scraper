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
         {:ok, utf8_body} <- sanitize(response),
         {:ok, body} <- Floki.parse_document(utf8_body) do
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

  # Some pages may not be encoded in UTF-8. This function attempts to
  # convert the response body to UTF-8 if it detects invalid UTF-8 sequences.
  defp sanitize(response) do
    body = response.body

    if String.valid?(body) do
      {:ok, body}
    else
      Logger.warning("Invalid UTF-8 detected in response. Attempting Latin-1 conversion.")

      # :unicode.characters_to_binary/3 is a powerful and safe way to convert.
      converted_body = :unicode.characters_to_binary(body, :latin1, :utf8)
      {:ok, converted_body}
    end
  end
end
