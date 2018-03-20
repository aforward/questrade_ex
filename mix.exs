defmodule QuestradeEx.Mixfile do
  use Mix.Project

  @name    :questrade_ex
  @version "0.1.0"

  @deps [
    {:mix_test_watch, "~> 0.3", only: :dev, runtime: false},
    {:jason, "~> 1.0"},
    {:httpoison, "~> 0.11.1"},
    {:fn_expr, "~> 0.2"},
    {:version_tasks, "~> 0.10"},
    {:ex_doc, ">= 0.0.0", only: :dev},
  ]

  @aliases [
  ]

  # ------------------------------------------------------------

  def project do
    in_production = Mix.env == :prod
    [
      app:     @name,
      version: @version,
      elixir:  ">= 1.6.0",
      deps:    @deps,
      aliases: @aliases,
      build_embedded:  in_production,
    ]
  end

  def application do
    [
      mod: { QuestradeEx.Application, [] },
      extra_applications: [
        :logger
      ],
    ]
  end

end
