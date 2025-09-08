defmodule LedgerApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :ledger,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "ledger",
      docs: &docs/0
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  def deps do
  [
    {:ex_doc, "~> 0.34", only: :dev, runtime: false, warn_if_outdated: true},
  ]
  end

  defp docs do
    [
      main: LedgerApp,
      extras: ["README.md"]
    ]
  end

  defp aliases do
    [

    ]
  end
end
