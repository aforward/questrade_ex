defmodule QuestradeEx.Worker do
  use GenServer
  use FnExpr
  alias GenServer, as: GS

  ### Public API

  def start_link(opts \\ []) do
    {:ok, _pid} = GS.start_link(__MODULE__, opts[:table], name: resolve(opts))
  end

  def assign_token(user, token, pid \\ nil) do
    GS.call(resolve(pid), {:assign_token, user, token})
  end

  def fetch_token(user, pid \\ nil), do: GS.call(resolve(pid), {:fetch_token, user})

  def clients(pid \\ nil), do: GS.call(resolve(pid), :clients)

  ### Server Callbacks

  def init(tablename) do
    pid = PersistentEts.new(:questrade_ex, tablename || "questrade_ex.tab", [:set, :protected])
    {:ok, [table: pid, users: restore_users(pid)]}
  end

  def handle_call({:assign_token, user, token}, _from, state) do
    :ets.insert(state[:table], {user, token})
    PersistentEts.flush(state[:table])

    state[:users]
    |> Map.put(user, token)
    |> invoke({:reply, token, Keyword.put(state, :users, &1)})
  end

  def handle_call({:fetch_token, user}, _from, state) do
    {:reply, state[:users][user], state}
  end

  def handle_call(:clients, _from, state) do
    {:reply, state[:users] |> Map.keys(), state}
  end

  defp restore_users(pid) do
    pid
    |> :ets.tab2list()
    |> Enum.into(%{})
  end

  defp resolve(opts) when is_list(opts), do: resolve(opts[:name])
  defp resolve(pid), do: pid || __MODULE__
end
