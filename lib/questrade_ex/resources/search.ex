defmodule QuestradeEx.Resources.Search do
  use FnExpr

  @doc """
  Locate a symbol's ID to enable other analysis about the stock.

  ## Examples

      QuestradeEx.Resources.Search.symbol_id("GS.TO")
      %{"currency" => "CAD",
        "description" => "GLUSKIN SHEFF SV",
        "isQuotable" => true,
        "isTradable" => true,
        "listingExchange" => "TSX",
        "securityType" => "Stock",
        "symbol" => "GS.TO",
        "symbolId" => 20374}
  """
  def symbol_id(user, symbol) do
    symbol
    |> String.split(".")
    |> List.first()
    |> invoke(fn prefix ->
      user
      |> QuestradeEx.request(:get, resource: "v1/symbols/search", params: [prefix: prefix])
      |> find_symbol(symbol)
    end)
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

  defp find_symbol({200, %{symbols: haystack}}, needle), do: find_symbol(haystack, needle)
  defp find_symbol({:error, _}, _needle), do: nil
  defp find_symbol([], _needle), do: nil
  defp find_symbol([%{symbol: needle} = data | _], needle), do: data
  defp find_symbol([_ | tail], needle), do: find_symbol(tail, needle)

  defp clean_symbol({200, %{symbols: haystack}}), do: List.first(haystack)
  defp clean_symbol({:error, _}), do: nil
end
