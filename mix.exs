defmodule QuestradeEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :questrade_ex,
      version: "0.2.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.3"},
      {:httpoison, "~> 1.3"},
      {:fn_expr, "~> 0.3"},
      {:version_tasks, "~> 0.12"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
