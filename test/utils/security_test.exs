defmodule QuestradeEx.SecurityTest do
  use ExUnit.Case, async: true
  alias QuestradeEx.Security
  doctest QuestradeEx.Security

  describe "encrypt/2" do
    test "based on the secret" do
      encrypted1a = Security.encrypt("hello", "shhh1")
      encrypted1b = Security.encrypt("hello", "shhh1")
      assert encrypted1a != encrypted1b

      encrypted2a = Security.encrypt("hello", "shhh2")
      encrypted2b = Security.encrypt("hello", "shhh2")
      assert encrypted2a != encrypted2b
    end
  end

  describe "decrypt/2" do
    test "based on the secret" do
      encrypted1 = Security.encrypt("hello", "shhh1")
      assert Security.decrypt(encrypted1, "shhh1") == {:ok, "hello"}

      encrypted2 = Security.encrypt("hello", "shhh2")
      assert Security.decrypt(encrypted2, "shhh2") == {:ok, "hello"}
    end

    test "handles nil" do
      {:error, message} = Security.decrypt(nil, "shhh1")
      assert message == nil
    end

    test "handles invalid challenges with nil" do
      encrypted1 = Security.encrypt("hello", "shhh1")
      {:error, message} = Security.decrypt(encrypted1, "shhh2")
      assert message =~ "Unable to decrypt"
    end
  end
end
