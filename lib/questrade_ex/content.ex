defmodule QuestradeEx.Content do
  @moduledoc """
  Transform, decode and analyze raw encoded content based on it's type
  (e.g. decode a raw JSON string into an Elixir map)
  """

  @doc """
  Extract the content type of the headers

  ## Examples

      iex> QuestradeEx.Content.type({:ok, "<xml />", [{"Server", "GitHub.com"}, {"Content-Type", "application/xml; charset=utf-8"}]})
      {:ok, "<xml />", "application/xml"}

      iex> QuestradeEx.Content.type([])
      "application/json"

      iex> QuestradeEx.Content.type([{"Content-Type", "plain/text"}])
      "plain/text"

      iex> QuestradeEx.Content.type([{"Content-Type", "application/xml; charset=utf-8"}])
      "application/xml"

      iex> QuestradeEx.Content.type([{"Server", "GitHub.com"}, {"Content-Type", "application/xml; charset=utf-8"}])
      "application/xml"
  """
  def type({ok, body, headers}), do: {ok, body, type(headers)}
  def type([]), do: "application/json"
  def type([{"Content-Type", val} | _]), do: val |> String.split(";") |> List.first()
  def type([_ | t]), do: t |> type

  @doc """
  Encode the body to pass along to the server

  ## Examples

      iex> QuestradeEx.Content.encode(nil, "anything")
      ""

      iex> QuestradeEx.Content.encode(%{a: 1}, "application/json")
      "{\\"a\\":1}"

      iex> QuestradeEx.Content.encode("<xml/>", "application/xml")
      "<xml/>"

      iex> QuestradeEx.Content.encode(%{a: "o ne"}, "application/x-www-form-urlencoded")
      "a=o+ne"

      iex> QuestradeEx.Content.encode("goop", "application/mytsuff")
      "goop"

  """
  def encode(nil, _), do: ""
  def encode(data, "application/json"), do: Jason.encode!(data)
  def encode(data, "application/xml"), do: data
  def encode(data, "application/x-www-form-urlencoded"), do: URI.encode_query(data)
  def encode(data, _), do: data

  @doc """
  Decode the response body

  ## Examples

      iex> QuestradeEx.Content.decode({:ok, "{\\\"a\\\": 1}", "application/json"})
      {:ok, %{a: 1}}

      iex> QuestradeEx.Content.decode({500, "", "application/json"})
      {500, ""}

      iex> QuestradeEx.Content.decode({:error, "{\\\"a\\\": 1}", "application/json"})
      {:error, %{a: 1}}

      iex> QuestradeEx.Content.decode({:ok, "{goop}", "application/json"})
      {:error, "{goop}"}

      iex> QuestradeEx.Content.decode({:error, "{goop}", "application/json"})
      {:error, "{goop}"}

      iex> QuestradeEx.Content.decode({:error, :nxdomain, "application/dontcare"})
      {:error, :nxdomain}

  """
  def decode({ok, body, _}) when is_atom(body), do: {ok, body}
  def decode({ok, "", _}), do: {ok, ""}

  def decode({ok, body, "application/json"}) when is_binary(body) do
    body
    |> Jason.decode(keys: :atoms)
    |> case do
      {:ok, parsed} -> {ok, parsed}
      _ -> {:error, body}
    end
  end

  def decode({ok, body, _}), do: {ok, body}
end
