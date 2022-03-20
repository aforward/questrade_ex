defmodule QuestradeEx.SettingsTest do
  use ExUnit.Case, async: true
  alias QuestradeEx.Settings
  doctest QuestradeEx.Settings

  describe "secret/1" do
    test "must be loaded with a password" do
      pid1 = settings(secret: "shhh1")
      pid2 = settings(secret: "shhh2")

      assert Settings.secret(pid1) == "shhh1"
      assert Settings.secret(pid2) == "shhh2"
    end
  end

  describe "encrypt/2" do
    test "based on the secret" do
      pid1 = settings(secret: "shhh1")
      pid2 = settings(secret: "shhh2")

      encrypted1a = Settings.encrypt("hello", pid1)
      encrypted1b = Settings.encrypt("hello", pid1)
      assert encrypted1a != encrypted1b

      encrypted2a = Settings.encrypt("hello", pid2)
      encrypted2b = Settings.encrypt("hello", pid2)
      assert encrypted2a != encrypted2b
    end
  end

  describe "decrypt/2" do
    test "based on the secret" do
      pid1 = settings(secret: "shhh1")
      pid2 = settings(secret: "shhh2")

      encrypted1 = Settings.encrypt("hello", pid1)
      assert Settings.decrypt(encrypted1, pid1) == {:ok, "hello"}

      encrypted2 = Settings.encrypt("hello", pid2)
      assert Settings.decrypt(encrypted2, pid2) == {:ok, "hello"}
    end

    test "handles invalid challenges with nil" do
      pid1 = settings(secret: "shhh1")
      pid2 = settings(secret: "shhh2")

      encrypted1 = Settings.encrypt("hello", pid1)
      {:error, message} = Settings.decrypt(encrypted1, pid2)
      assert message =~ "Unable to decrypt"
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
