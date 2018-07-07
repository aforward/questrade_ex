defmodule QuestradeEx.Worker do
  use GenServer
  use FnExpr
  alias GenServer, as: GS

  ### Public API

  def start_link(name \\ nil) do
    {:ok, _pid} = GS.start_link(__MODULE__, %{}, name: resolve(name))
  end

  def assign_token(user, token, pid \\ nil) do
    GS.call(resolve(pid), {:assign_token, user, token})
  end

  def fetch_token(user, pid \\ nil) do
    GS.call(resolve(pid), {:fetch_token, user})
  end

  ### Server Callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_call({:assign_token, user, token}, _from, state) do
    state
    |> Map.put(user, token)
    |> invoke({:reply, token, &1})
  end

  def handle_call({:fetch_token, user}, _from, state) do
    {:reply, state[user], state}
  end

  defp resolve(pid), do: pid || __MODULE__

end
