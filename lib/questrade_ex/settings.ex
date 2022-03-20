defmodule QuestradeEx.Settings do
  alias GenServer, as: GS

  # Use AES 128 Bit Keys for Encryption.
  @block_size 16

  def start_link(opts \\ []) do
    {:ok, _pid} = GS.start_link(__MODULE__, opts[:secret], name: resolve(opts))
  end

  def init(secret) do
    {:ok, %{secret: secret}}
  end

  def secret(pid \\ nil), do: GS.call(resolve(pid), :secret)

  def encrypt(message, pid \\ nil), do: GS.call(resolve(pid), {:encrypt, message})

  def decrypt(message, pid \\ nil), do: GS.call(resolve(pid), {:decrypt, message})

  def handle_call(:secret, _from, state) do
    {:reply, state[:secret], state}
  end

  def handle_call({:encrypt, message}, _from, state) do
    iv = iv()

    encrypted =
      (iv <> :crypto.crypto_one_time(:aes_128_cbc, crypto_key(state), iv, pad(message), true))
      |> :base64.encode()

    {:reply, encrypted, state}
  end

  def handle_call({:decrypt, message}, _from, state) do
    ciphertext = :base64.decode(message)
    <<iv::binary-16, ciphertext::binary>> = ciphertext

    decrypted =
      :crypto.crypto_one_time(:aes_128_cbc, crypto_key(state), iv, ciphertext, false)
      |> unpad()

    {:reply, decrypted, state}
  end

  defp crypto_key(%{secret: secret}) do
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

  defp resolve(opts) when is_list(opts), do: resolve(opts[:name])
  defp resolve(pid), do: pid || __MODULE__
end
