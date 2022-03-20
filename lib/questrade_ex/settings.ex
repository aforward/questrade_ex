defmodule QuestradeEx.Settings do
  alias GenServer, as: GS

  def start_link(opts \\ []) do
    {:ok, _pid} = GS.start_link(__MODULE__, opts[:secret], name: resolve(opts))
  end

  def init(secret) do
    {:ok, %{secret: secret}}
  end

  def secret(pid \\ nil), do: GS.call(resolve(pid), :secret)

  def handle_call(:secret, _from, state) do
    {:reply, state[:secret], state}
  end

  defp resolve(opts) when is_list(opts), do: resolve(opts[:name])
  defp resolve(pid), do: pid || __MODULE__
end
