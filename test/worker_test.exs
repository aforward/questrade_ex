defmodule QuestradeEx.WorkerTest do
  use ExUnit.Case
  alias QuestradeEx.Worker, as: W
  doctest QuestradeEx.Worker

  test "fetch existig token" do
    token = %{
      access_token: "abc123",
      api_server: "https://qt.com",
      expires_in: 1800,
      refresh_token: "def456",
      token_type: "Bearer"
    }

    W.assign_token("me", token)
    assert token == W.fetch_token("me")
  end
end
