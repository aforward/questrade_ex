defmodule QuestradeEx.Mixfile do
  use Mix.Project

  @name :questrade_ex
  @version "0.2.0"

  @deps [
    {:mix_test_watch, "~> 0.3", only: :dev, runtime: false},
    {:jason, "~> 1.1"},
    {:httpoison, "~> 1.3"},
    {:fn_expr, "~> 0.3"},
    {:version_tasks, "~> 0.11"},
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
      elixir: "~> 1.8.0",
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
