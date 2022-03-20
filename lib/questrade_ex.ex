defmodule QuestradeEx do
  @moduledoc """
  A client API to the QuestradeEx API.

  To access direct calls to the service, you will want to use the
  `QuestradeEx.Api` module.  When making requests, you can provide
  several `opts`, all of which can be defaulted using `Mix.Config`.

  Here is an example of how to configure this library

      config :questrade_ex,
        base: "https://login.questrade.com/oauth2",

        # if you have Basic Authentication
        basic_auth: "api:abc123",

        # if you have Basic Username / Password
        basic_user: "api",
        basic_password: "abc123",

        # if you have OAuth2 Authentication (aka Bearer)
        bearer_auth: "def456",

        #
        http_opts: %{
          timeout: 5000,
        }

  Our default `mix test` tests will use [Bypass](https://hex.pm/packages/bypass)
  as the `base` service URL so that we will not hit your production Questrade
  account during testing.

  Here is an outline of all the configurations you can set.

    * `:base`             - The base URL which defaults to `https://login.questrade.com/oauth2`
    * `:basic_auth`       - Your basic authentication user name / shared key as one value, which might look like `api:abc123`
    * `:basic_user`       - Your basic authentication split between user
    * `:basic_password`   - And the password for that basic authentication
    * `:bearer_auth`      - Maybe you are using bearer authentication (think OAuth2)
    * `:http_opts`        - A passthrough map of options to send to HTTP request, more details below

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

  """

  defdelegate access_token(token), to: QuestradeEx.Client

  defdelegate refresh_token(token), to: QuestradeEx.Client

  @doc """
  See the underlying client method for more details.

  To extract your account information

  ```elixir
  QuestradeEx.request(token, :get, resource: "v1/accounts")
  ```

  To lookup companies

  ```elixir
  QuestradeEx.request(token, :get, resource: "v1/symbols/search", params: [prefix: "AAPL"])
  ```

  With a sample reply like:

  ```elixir
  %{
       currency: "USD",
       description: "APPLE INC",
       isQuotable: true,
       isTradable: true,
       listingExchange: "NASDAQ",
       securityType: "Stock",
       symbol: "AAPL",
       symbolId: 8049
     }
  ```


  To lookup a specific symbol

  ```elixir
  QuestradeEx.request(token, :get, resource: "v1/symbols/8049")
  ```

  With a sample reply like

  ```elixir
  %{
   symbols: [
     %{
       pe: 26.63682,
       isTradable: true,
       industrySector: "Technology",
       minTicks: [%{minTick: 1.0e-4, pivot: 0}, %{minTick: 0.01, pivot: 1}],
       tradeUnit: 1,
       averageVol3Months: 92733375,
       currency: "USD",
       optionStrikePrice: nil,
       highPrice52: 182.94,
       optionExpiryDate: nil,
       dividend: 0.22,
       industrySubgroup: "Undefined",
       hasOptions: true,
       isQuotable: true,
       industryGroup: "Undefined",
       listingExchange: "NASDAQ",
       optionRoot: "",
       symbolId: 8049,
       marketCap: 2621228613400,
       yield: 0.54788,
       lowPrice52: 118.86,
       optionExerciseType: nil,
       dividendDate: "2022-02-10T00:00:00.000000-05:00",
       optionDurationType: nil,
       prevDayClosePrice: 163.98,
       description: "APPLE INC",
       exDate: "2022-02-04T00:00:00.000000-05:00",
       optionContractDeliverables: %{cashInLieu: 0, underlyings: []},
       averageVol20Days: 97763442,
       securityType: "Stock",
       symbol: "AAPL",
       optionType: nil,
       outstandingShares: 16319440000,
       eps: 6.03
     }
   ]
  }
  ```
  """
  defdelegate request(token, method, base_opts \\ []), to: QuestradeEx.Client
end
