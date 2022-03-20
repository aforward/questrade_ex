defmodule QuestradeEx.Settings do
  alias GenServer, as: GS
  alias QuestradeEx.Security

  def start_link(opts \\ []) do
    {:ok, _pid} =
      GS.start_link(__MODULE__, Keyword.get(opts, :secret, Security.secret()), name: resolve(opts))
  end

  def init(secret) do
    {:ok, %{secret: secret || :crypto.strong_rand_bytes(10), tokens: %{}}}
  end

  def secret(pid \\ nil), do: GS.call(resolve(pid), :secret)

  def set_token(user, token, pid \\ nil), do: GS.call(resolve(pid), {:set_token, user, token})

  def get_token(user, pid \\ nil), do: GS.call(resolve(pid), {:get_token, user})

  def handle_call(:secret, _from, state) do
    {:reply, state[:secret], state}
  end

  def handle_call({:set_token, user, token}, _from, state) do
    encrypted = Security.encrypt(token, state[:secret])

    new_state =
      state
      |> Map.update!(:tokens, &Map.put(&1, user, encrypted))

    {:reply, encrypted, new_state}
  end

  def handle_call({:get_token, user}, _from, state) do
    decrypted =
      state
      |> Map.get(:tokens)
      |> Map.get(user)
      |> Security.decrypt(state[:secret])
      |> case do
        {:error, nil} -> {:error, :missing_token}
        asis -> asis
      end

    {:reply, decrypted, state}
  end

  defp resolve(opts) when is_list(opts), do: resolve(opts[:name])
  defp resolve(pid), do: pid || __MODULE__
end
