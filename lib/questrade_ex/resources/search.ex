defmodule QuestradeEx.Resources.Search do
  use FnExpr

  @doc """
  Locate a symbol's ID to enable other analysis about the stock.

  ## Examples

      QuestradeEx.Resources.Search.symbol_id("me", {"TSX", "T"})
      %{
        currency: "CAD",
        description: "TELUS CORPORATION",
        isQuotable: true,
        isTradable: true,
        listingExchange: "TSX",
        securityType: "Stock",
        symbol: "T.TO",
        symbolId: 38347
      }

      QuestradeEx.Resources.Search.symbol_id("me", "GS.TO")
      %{
        currency: "CAD",
        description: "GLUSKIN SHEFF   ASSOCIATES INC.",
        isQuotable: true,
        isTradable: true,
        listingExchange: "TSX",
        securityType: "Stock",
        symbol: "GS.TO",
        symbolId: 20374
      }

      QuestradeEx.Resources.Search.symbol_id("me", {"NASDAQ", "T"})
      %{
        currency: "USD",
        description: "AT&T Inc.",
        isQuotable: true,
        isTradable: true,
        listingExchange: "NYSE",
        securityType: "Stock",
        symbol: "T",
        symbolId: 6280
      }

      QuestradeEx.Resources.Search.symbol_id("me", "AAPL")
      %{
        currency: "USD",
        description: "Apple Inc.",
        isQuotable: true,
        isTradable: true,
        listingExchange: "NASDAQ",
        securityType: "Stock",
        symbol: "AAPL",
        symbolId: 8049
      }

      QuestradeEx.Resources.Search.symbol_id("me", {"TSX", "AX.UN"})
      %{
        currency: "CAD",
        description: "ARTIS REAL ESTATE INVESTMENT TRUST UNITS",
        isQuotable: true,
        isTradable: true,
        listingExchange: "TSX",
        securityType: "Stock",
        symbol: "AX.UN.TO",
        symbolId: 8313
      }
  """
  def symbol_id(user, {_exchange, ticker} = qualified_ticker) do
    user
    |> QuestradeEx.request(:get, resource: "v1/symbols/search", params: [prefix: ticker])
    |> case do
      {200, %{symbols: haystack}} ->
        haystack
        |> Enum.filter(&symbol?(qualified_ticker, &1))
        |> List.first()

      {:error, _} ->
        nil
    end
  end

  @doc """
  Locate information about a symbol
  """
  def lookup_symbol(user, symbol) do
    user
    |> symbol_id(symbol)
    |> case do
      %{symbolId: id} ->
        user
        |> QuestradeEx.request(:get, resource: "v1/symbols/#{id}")
        |> clean_symbol

      resp ->
        resp
    end
  end

  defp clean_symbol({200, %{symbols: haystack}}), do: List.first(haystack)
  defp clean_symbol({:error, _}), do: nil

  defp symbol?({"TSX", ticker}, data) do
    data[:symbol] == "#{ticker}.TO" && data[:listingExchange] == "TSX"
  end

  defp symbol?({:unknown, ticker}, data), do: data[:symbol] == ticker

  defp symbol?({exchange, ticker}, data) do
    data[:symbol] == ticker && data[:listingExchange] == exchange
  end

  defp symbol?(_, _), do: false
end
