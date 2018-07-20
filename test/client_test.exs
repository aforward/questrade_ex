defmodule QuestradeEx.ClientTest do
  use ExUnit.Case, async: false
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

  test "refresh token missing" do
    assert {:error, :missing_token} = Client.refresh_token("y")
  end

  @tag :external
  test "refresh token invalid" do
    Client.assign_token(%{refresh_token: "abc123"}, "p")
    assert {:error, "Bad Request"} = Client.refresh_token("p")
  end

  @tag :external
  test "bad refresh token" do
    assert Client.fetch_token("you", "badtoken") == {:error, "Bad Request"}
  end

  @tag :external
  test "make use of the token and do lots of testing (only 1 token, so 1 test)" do
    refresh_token = System.get_env("QUESTRADE_REFRESH_TOKEN")
    assert refresh_token != nil

    assert {:ok, token} = Client.fetch_token("me", refresh_token)
    IO.inspect(token)

    assert token[:access_token] != nil
    assert token[:api_server] != nil
    assert token[:expires_in] == 1800
    assert token[:refresh_token] != nil
    assert token[:token_type] == "Bearer"

    {:ok, same_token} = Client.fetch_token("me")
    assert token == same_token

    {200, data} = Client.request_once("me", :get, resource: "v1/markets")
    assert data[:markets] != nil

    {:ok, new_token} = Client.refresh_token("me")
    IO.inspect(new_token)
    assert same_token != new_token

    wait_for_worker()
    {200, data} = Client.request_once("me", :get, resource: "v1/markets")
    assert data[:markets] != nil

    {:ok, same_new_token} = Client.fetch_token("me")
    assert same_new_token == new_token

    wait_for_worker()
    {200, data} = Client.request_once("me", :get, resource: "v1/markets")
    assert data[:markets] != nil

    Client.assign_token(same_token, "me")

    wait_for_worker()
    reply = Client.request_once("me", :get, resource: "v1/markets")
    assert reply == {401, %{code: 1017, message: "Access token is invalid"}}

    Client.assign_token(new_token, "me")

    wait_for_worker()
    {200, data} = Client.request_retry(reply, "me", :get, resource: "v1/markets")
    assert data[:markets] != nil

    assert "anything" == Client.request_retry("anything", "me", :get, resource: "v1/markets")

    {:ok, new_new_token} = Client.fetch_token("me")
    assert new_new_token != new_token
    assert new_new_token != token

    wait_for_worker()
    {200, data} = Client.request("me", :get, resource: "v1/markets")
    assert data[:markets] != nil

    {:ok, same_new_new_token} = Client.fetch_token("me")
    assert same_new_new_token == new_new_token
  end

  defp wait_for_worker() do
    [{_, pid, _, _}] = Supervisor.which_children(QuestradeEx.Supervisor)
    :sys.get_state(pid)
    :timer.sleep(1200)
  end
end
