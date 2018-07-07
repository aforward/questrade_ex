defmodule QuestradeEx.WorkerTest do
  use ExUnit.Case, async: true
  alias QuestradeEx.Worker, as: W
  doctest QuestradeEx.Worker

  test "fetch existig token" do
    pid = worker()
    token = token(%{access_token: "abc123"})
    W.assign_token("me", token, pid)
    assert token == W.fetch_token("me", pid)
  end

  def token(overrides \\ %{}) do
    %{
      access_token: "abc123",
      api_server: "https://qt.com",
      expires_in: 1800,
      refresh_token: "def456",
      token_type: "Bearer"
    }
    |> Map.merge(overrides)
  end

  def worker() do
    "t#{:rand.uniform(10)}"
    |> String.to_atom()
    |> W.start_link()
    |> case do
      {:ok, pid} -> pid
    end
  end
end
