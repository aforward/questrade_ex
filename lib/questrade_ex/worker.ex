defmodule QuestradeEx.Worker do
  use GenServer
  use FnExpr
  alias GenServer, as: GS
  alias QuestradeEx.Worker, as: W

  ### Public API

  def start_link() do
    {:ok, _pid} = GS.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def assign_token(user, token) do
    GS.call(W, {:assign_token, user, token})
  end

  def fetch_token(user) do
    GS.call(W, {:fetch_token, user})
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
end
