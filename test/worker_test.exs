defmodule QuestradeEx.WorkerTest do
  use ExUnit.Case, async: false
  alias QuestradeEx.Worker, as: W
  doctest QuestradeEx.Worker

  setup do
    File.rm("questrade_ex.tab")
    File.rm("questrade_ex_1.tab")
    :ok
  end

  test "fetch existig token" do
    pid = worker()
    token = token(%{access_token: "abc123"})
    W.assign_token("me", token, pid)
    assert token == W.fetch_token("me", pid)

    assert ["me"] == W.clients(pid)
  end

  test "persist tokens for restart" do
    pid1 = worker(table: "questrade_ex_1.tab")

    t1 = token(%{access_token: "abc123"})
    t2 = token(%{access_token: "def456"})

    W.assign_token("me", t1, pid1)
    W.assign_token("you", t2, pid1)

    Process.exit(pid1, :normal)

    pid2 = worker(table: "questrade_ex_1.tab")
    assert t1 == W.fetch_token("me", pid2)
    assert t2 == W.fetch_token("you", pid2)
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

  def worker(opts \\ []) do
    opts
    |> Keyword.put(:name, "t#{:rand.uniform(10)}" |> String.to_atom())
    |> W.start_link()
    |> case do
      {:ok, pid} -> pid
    end
  end
end
