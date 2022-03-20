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

  def settings(opts \\ []) do
    opts
    |> Keyword.put(:name, "t#{:rand.uniform(100_000)}" |> String.to_atom())
    |> Settings.start_link()
    |> case do
      {:ok, pid} -> pid
    end
  end
end
