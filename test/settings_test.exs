defmodule QuestradeEx.SettingsTest do
  use ExUnit.Case, async: true
  alias QuestradeEx.{Settings, Security}
  doctest QuestradeEx.Settings

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

      encrypted = Settings.set_token("aforward@hey.com", "abc123", pid)
      assert Security.decrypt(encrypted, "shhh1") == {:ok, "abc123"}
    end
  end

  describe "get_token/2" do
    test "no token available" do
      pid = settings(secret: "shhh1")
      assert Settings.get_token("aforward@hey.com", pid) == {:error, nil}
    end

    test "decrypted" do
      pid = settings(secret: "shhh1")

      Settings.set_token("aforward@hey.com", "def456", pid)
      assert Settings.get_token("aforward@hey.com", pid) == {:ok, "def456"}
    end

    test "handles errors" do
      pid1 = settings(secret: "shhh1")
      pid2 = settings(secret: "shhh2")

      Settings.set_token("aforward@hey.com", "abc123", pid1)
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
