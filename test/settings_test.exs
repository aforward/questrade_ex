defmodule QuestradeEx.SettingsTest do
  use ExUnit.Case, async: true
  alias QuestradeEx.{Settings, Security}
  doctest QuestradeEx.Settings

  @token %{
    access_token: "abc123",
    api_server: "https://api07.iq.questrade.com/",
    expires_in: 1800,
    refresh_token: "abc129",
    token_type: "Bearer"
  }

  @token2 %{
    access_token: "def456",
    api_server: "https://api07.iq.questrade.com/",
    expires_in: 1800,
    refresh_token: "def459",
    token_type: "Bearer"
  }

  describe "secret/1" do
    test "must be loaded with a password" do
      pid1 = settings(secret: "shhh1")
      pid2 = settings(secret: "shhh2")

      assert Settings.secret(pid1) == "shhh1"
      assert Settings.secret(pid2) == "shhh2"
    end

    test "generate one if none provided" do
      pid = settings()
      assert Settings.secret(pid) != nil
    end
  end

  describe "set_token/3" do
    test "encryptes the token" do
      pid = settings(secret: "shhh1")
      encrypted = Settings.set_token("aforward@hey.com", @token, pid)
      assert Security.decrypt(encrypted, "shhh1") == {:ok, @token}
    end
  end

  describe "get_token/2" do
    test "no token available" do
      pid = settings(secret: "shhh1")
      assert Settings.get_token("aforward@hey.com", pid) == {:error, :missing_token}
    end

    test "decrypted" do
      pid = settings(secret: "shhh1")

      Settings.set_token("aforward@hey.com", @token2, pid)
      assert Settings.get_token("aforward@hey.com", pid) == {:ok, @token2}
    end

    test "handles errors" do
      pid1 = settings(secret: "shhh1")
      pid2 = settings(secret: "shhh2")

      Settings.set_token("aforward@hey.com", @token, pid1)
      {:error, _msg} = Settings.get_token("aforward@hey.com", pid2)
    end
  end

  def settings(opts \\ []) do
    opts
    |> Keyword.put(:name, "t#{:rand.uniform(100_000)}" |> String.to_atom())
    |> Settings.start_link()
    |> case do
      {:ok, pid} -> pid
    end
  end
end
