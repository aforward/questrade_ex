defmodule QuestradeEx.Url do
  @moduledoc """
  Generate the appropriate QuestradeEx URL based on the sending
  domain, and the desired resource.
  """

  @base_url "https://login.questrade.com/oauth2"

  alias QuestradeEx.{Opts}

  @doc """
  The API url for your domain, configurable using several `opts`
  (Keyword list of options).

  ## Available options:

    * `:base` - The base URL which defaults to `https://login.questrade.com/oauth2`
    * `:resource` - The requested resource (e.g. /domains)

  The options above can be defaulted using `Mix.Config` configurations,
  please refer to `QuestradeEx` for more details on configuring this library.

  This function returns a fully qualified URL as a string.

  ## Example

      iex> QuestradeEx.Url.generate()
      "https://login.questrade.com/oauth2"

      iex> QuestradeEx.Url.generate(base: "http://localhost:4000/v2")
      "http://localhost:4000/v2"

      iex> QuestradeEx.Url.generate(base: "http://localhost:4000/v2", resource: "stuff")
      "http://localhost:4000/v2/stuff"

      iex> QuestradeEx.Url.generate(base: "http://localhost:4000/v2/", resource: "stuff")
      "http://localhost:4000/v2/stuff"

      iex> QuestradeEx.Url.generate(base: "http://localhost:4000/v2/", resource: "/stuff")
      "http://localhost:4000/v2/stuff"

      iex> QuestradeEx.Url.generate(base: "http://localhost:4000/v2", resource: "/stuff")
      "http://localhost:4000/v2/stuff"

      iex> QuestradeEx.Url.generate()
      "https://login.questrade.com/oauth2"

      iex> QuestradeEx.Url.generate(resource: "logs")
      "https://login.questrade.com/oauth2/logs"

      iex> QuestradeEx.Url.generate(resource: "tags/t1")
      "https://login.questrade.com/oauth2/tags/t1"

      iex> QuestradeEx.Url.generate(resource: ["tags", "t1", "stats"])
      "https://login.questrade.com/oauth2/tags/t1/stats"

  """
  def generate(opts \\ []) do
    opts
    |> Opts.merge([:base, :resource])
    |> (fn all_opts ->
          [
            Keyword.get(all_opts, :base, @base_url),
            Keyword.get(all_opts, :resource, [])
          ]
        end).()
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
    |> Enum.map(fn s -> s |> String.trim("/") end)
    |> Enum.join("/")
  end
end
