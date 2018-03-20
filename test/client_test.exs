defmodule QuestradeEx.ClientTest do
  use ExUnit.Case
  alias QuestradeEx.Client
  doctest QuestradeEx.Client

  setup do
    Application.put_env(:questrade_ex, :base, "https://login.questrade.com/oauth2")

    on_exit(fn ->
      Application.delete_env(:questrade_ex, :base)
    end)

    :ok
  end

  test "assign / fetch token directly" do
    Client.assign_token(%{token: "abc123"}, "x")
    assert {:ok, %{token: "abc123"}} == Client.fetch_token("x")
  end

  test "fetch missing token" do
    assert {:error, :missing_token} = Client.fetch_token("y")
  end

  @tag :external
  test "bad refresh token" do
    assert Client.fetch_token("you", "badtoken") == {:error, "Bad Request"}
  end

  @tag :external
  test "create a token based on configured refresh_token" do
    refresh_token = System.get_env("QUESTRADE_REFRESH_TOKEN")
    assert refresh_token != nil

    assert {:ok, token} = Client.fetch_token("me", refresh_token)

    assert token[:access_token] != nil
    assert token[:api_server] != nil
    assert token[:expires_in] == 1800
    assert token[:refresh_token] != nil
    assert token[:token_type] == "Bearer"

    {:ok, same_token} = Client.fetch_token("me")
    assert token == same_token
  end
end
