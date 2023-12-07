defmodule MyFinch do
  Finch.start_link(name: MyFinch)
end

defmodule Giphyscraper do
  require Logger

  @base_url "https://api.giphy.com/v1/gifs/search"
  @api_key "toJWX4QFaL2RCjL7NA6GlQderllrTqSo"

  defstruct [:id, :url, :username, :title]

  @spec parse_gif(map()) :: %Giphyscraper{id: any(), title: any(), url: any(), username: any()}
  def parse_gif(%{"id" => id, "url" => url, "username" => username, "title" => title}) do
    %__MODULE__{id: id, url: url, username: username, title: title}
  end

  def search(query) when is_binary(query) do
    query_params = %{"q" => query, "api_key" => @api_key, "limit" => 25}
    headers = [{"User-Agent", "Giphyscraper"}]
    url = @base_url

    case MyFinch.get(url, headers, query_params) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        body
        |> Jason.decode!()
        |> Map.get("data")
        |> Enum.map(&parse_gif/1)

      {:ok, %Finch.Response{status: status}} when status != 200 ->
        Logger.error("Received non-200 response: #{status}")
        []

      {:error, reason} ->
        Logger.error("Request failed: #{inspect(reason)}")
        []
    end
  end
end
