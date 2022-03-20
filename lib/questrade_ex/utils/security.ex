defmodule QuestradeEx.Security do
  # Use AES 128 Bit Keys for Encryption.
  @block_size 16

  def secret(), do: :crypto.strong_rand_bytes(16)

  def encrypt(message, secret) do
    iv = iv()

    (iv <> :crypto.crypto_one_time(:aes_128_cbc, crypto_key(secret), iv, pad(message), true))
    |> :base64.encode()
  end

  def decrypt(nil, _secret), do: {:error, nil}

  def decrypt(message, secret) do
    ciphertext = :base64.decode(message)
    <<iv::binary-16, ciphertext::binary>> = ciphertext

    :crypto.crypto_one_time(:aes_128_cbc, crypto_key(secret), iv, ciphertext, false)
    |> unpad()
  end

  defp crypto_key(secret) do
    <<crypto_secret::binary-16, _::binary>> = :crypto.hash(:sha256, secret)
    crypto_secret
  end

  defp iv(), do: :crypto.strong_rand_bytes(16)

  defp pad(data) do
    to_add = @block_size - rem(byte_size(data), @block_size)
    data <> to_string(:string.chars(to_add, to_add))
  end

  defp unpad(data) do
    end_index = byte_size(data) - :binary.last(data)

    if end_index >= 0 do
      {:ok, :binary.part(data, 0, end_index)}
    else
      {:error, "Unable to decrypt '#{data |> inspect()}'"}
    end
  end
end
