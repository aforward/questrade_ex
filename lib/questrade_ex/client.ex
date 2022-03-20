defmodule QuestradeEx.Client do
  alias QuestradeEx.Api

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

  @doc """
  Extract the access_token from the user.

  If you provide a string (binary) then that means you manually
  created one from the Questrade UI
  https://apphub.questrade.com/UI/UserApps.aspx

  For example,

  ```elixir
  QuestradeEx.Client.access_token("wmABCKacPC5MCwT-DefaqYKQloH123ZyR0")
  ```

  It will return the access_token, if generated

  ```elixir
  %{
    access_token: "abcvwakdefDxYxYnhijl9Tq90210yj344j0",
    api_server: "https://api07.iq.questrade.com/",
    expires_in: 1800,
    refresh_token: "abc6V7defRIdhijLO5123Q1j90210cK0P70",
    token_type: "Bearer"
  }
  ```

  If that token is no longer valid, the reply will look like

  ```
  nil
  ```

  If you already have the full token, it will return what
  you provided :-)
  """
  def access_token(token) when is_map(token), do: token

  def access_token(refresh_token), do: refresh_token(refresh_token)

  @doc """
  Refresh the access token.  If you provide a string, that
  means you created one manually.

  ```elixir
  Token.refresh_token("wmABCKacPC5MCwT-DefaqYKQloH123ZyR0")
  ```

  If you have a _now_ expired token, then you will need to
  extract the refresh_token from the token.

  ```elixir
  Token.refresh_token(%{refresh_token: "wmABCKacPC5MCwT-DefaqYKQloH123ZyR0"})
  ```

  The results will look similar as &access_token/1
  """
  def refresh_token(%{refresh_token: refresh_token}), do: refresh_token(refresh_token)

  def refresh_token(refresh_token) when is_binary(refresh_token) do
    Api.request(
      :post,
      resource: "/token",
      body: %{grant_type: :refresh_token, refresh_token: refresh_token},
      headers: [{"Content-Type", "application/x-www-form-urlencoded"}]
    )
    |> case do
      {200, token} -> token
      _error -> nil
    end
  end

  @doc """
  Once you have a token, you can make authenticated requests, such as

  ```elixir
  QuestradeEx.authenticated_request(token, :get, resource: "v1/accounts")
  ```

  Which will return something like

  ```elixir
  {200,
   %{
     accounts: [
       %{
         clientAccountType: "Individual",
         isBilling: true,
         isPrimary: true,
         number: "55511111",
         status: "Active",
         type: "TFSA"
       },
       %{
         clientAccountType: "Individual",
         isBilling: false,
         isPrimary: false,
         number: "444222222",
         status: "Active",
         type: "RRSP"
       }
     ],
     userId: 90210
   }}
  ```
  """
  def request(token, method), do: request(token, method, [])

  def request(token, method, base_opts) when is_binary(token) do
    new_token = access_token(token)
    {ok, answer, _} = request(new_token, method, base_opts)
    {ok, answer, new_token}
  end

  def request(token, method, base_opts) when is_map(token) do
    token
    |> call_once(method, base_opts)
    |> case do
      {:error, {401, %{code: 1017}}, bad_token} ->
        bad_token
        |> refresh_token()
        |> call_once(method, base_opts)

      answer ->
        answer
    end
  end

  defp call_once(token, method, base_opts) do
    opts =
      base_opts
      |> Keyword.put(:base, token[:api_server])
      |> Keyword.put(:bearer_auth, token[:access_token])

    expected_code = Keyword.get(opts, :expected_code, 200)

    Api.request(method, opts)
    |> case do
      {^expected_code, good_answer} -> {:ok, good_answer, token}
      bad_answer -> {:error, bad_answer, token}
    end
  end
end
