defmodule KoombeaScraper.Client do
  @moduledoc """
  A client to scrape a web page and extract its title and links.
  """

  @doc """
  Scrapes a given URL and returns the page title and a list of links.
  """
  def scrape(url) do
    with {:ok, response} <- Req.get(url),
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
      {:error, reason} -> {:error, reason}
    end
  end
end
