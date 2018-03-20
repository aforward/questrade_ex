defmodule QuestradeEx.Application do

  @moduledoc false

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(QuestradeEx.Worker, []),
    ]

    opts = [
      strategy: :one_for_one,
      name:     QuestradeEx.Supervisor
    ]

    Supervisor.start_link(children, opts)
  end
end
