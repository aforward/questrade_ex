defmodule QuestradeEx.Client do
  @moduledoc """
  Helper functions to access the QuestradeEx API in a
  more succinct way.  If any features of the API are
  not directly available here, then consider using
  the `QuestradeEx.Api` module directly, or raising a PR
  to add them to the client.

  All client functions includes a `opts` argument that
  can accept any lower level options including those
  for `&QuestradeEx.Api.request/2`

  Here is an outline of all the configurations you can set.

    * `:base`      - The base URL which defaults to `https://login.questrade.com/oauth2`
    * `:http_opts` - A passthrough map of options to send to HTTP request, more details below

  This client library uses [HTTPoison](https://hex.pm/packages/httpoison)
  for all HTTP communication, and we will pass through any `:http_opts` you provide,
  which we have shown below.

    * `:timeout`          - timeout to establish a connection, in milliseconds. Default is 8000
    * `:recv_timeout`     - timeout used when receiving a connection. Default is 5000
    * `:stream_to`        - a PID to stream the response to
    * `:async`            - if given :once, will only stream one message at a time, requires call to stream_next
    * `:proxy`            - a proxy to be used for the request; it can be a regular url or a {Host, Port} tuple
    * `:proxy_auth`       - proxy authentication {User, Password} tuple
    * `:ssl`              - SSL options supported by the ssl erlang module
    * `:follow_redirect`  - a boolean that causes redirects to be followed
    * `:max_redirect`     - an integer denoting the maximum number of redirects to follow
    * `:params`           - an enumerable consisting of two-item tuples that will be appended to the url as query string parameters

  If the above values do not change between calls, then consider configuring
  them with `Mix.Config` to avoid using them throughout your code.
  """

  use FnExpr
  alias QuestradeEx.{Api, Worker}

  @doc """
  Make an API call, possibly requiring a refreshed token
  """
  def request(user, method, opts) do
    user
    |> request_once(method, opts)
    |> request_retry(user, method, opts)
  end

  @doc """
  Make an API call to questrade for the provided user using the available token
  """
  def request_once(user, method, opts) do
    user
    |> fetch_token
    |> do_request(method, opts)
  end

  @doc """
  Interpret the results of an API request, and possibly retry if we encounter
  something that is retryable
  """
  def request_retry({401, %{code: 1017}}, user, method, opts) do
    user
    |> refresh_token
    |> do_request(method, opts)
  end

  def request_retry(other_response, _user, _method, _opts), do: other_response

  @doc """
  Fetch a token based on the provided refresh_token for the user
  """
  def fetch_token(user, refresh_token) do
    Api.request(
      :post,
      resource: "/token",
      body: %{grant_type: :refresh_token, refresh_token: refresh_token},
      headers: [{"Content-Type", "application/x-www-form-urlencoded"}]
    )
    |> assign_token(user)
  end

  @doc """
  Fetch the stored token for the user, if none return an error
  """
  def fetch_token(user) do
    case Worker.fetch_token(user) do
      nil -> {:error, :missing_token}
      token -> {:ok, token}
    end
  end

  @doc """
  Refresh the token
  """
  def refresh_token(user) do
    user
    |> fetch_token
    |> case do
      {:ok, %{refresh_token: refresh_token}} -> fetch_token(user, refresh_token)
      reply -> reply
    end
  end

  @doc """
  Maybe you have a legit token, here's how how you can set it directly
  """
  def assign_token({200, token}, user), do: {:ok, Worker.assign_token(user, token)}
  def assign_token({_, reason}, _), do: {:error, reason}
  def assign_token(token, user), do: Worker.assign_token(user, token)

  defp do_request(
         {:ok, %{api_server: base_url, access_token: token, token_type: "Bearer"}},
         method,
         opts
       ) do
    opts
    |> Keyword.put(:base, base_url)
    |> Keyword.put(:bearer_auth, token)
    |> invoke(Api.request(method, &1))
  end

  defp do_request(other_response, _method, _opts), do: other_response
end
