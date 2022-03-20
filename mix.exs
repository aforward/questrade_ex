defmodule QuestradeEx.Mixfile do
  use Mix.Project

  @name :questrade_ex
  @version "0.2.0"

  @deps [
    {:jason, "~> 1.3"},
    {:httpoison, "~> 1.3"},
    {:fn_expr, "~> 0.3"},
    {:version_tasks, "~> 0.12"},
    {:persistent_ets, github: "michalmuskala/persistent_ets"},
    {:ex_doc, ">= 0.0.0", only: :dev}
  ]

  @aliases []

  # ------------------------------------------------------------

  def project do
    in_production = Mix.env() == :prod

    [
      app: @name,
      version: @version,
      elixir: "~> 1.13",
      deps: @deps,
      aliases: @aliases,
      build_embedded: in_production
    ]
  end

  def application do
    [
      mod: {QuestradeEx.Application, []},
      extra_applications: [
        :logger
      ]
    ]
  end
end
