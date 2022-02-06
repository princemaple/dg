defmodule DG.MixProject do
  use Mix.Project

  @source_url "https://github.com/princemaple/dg"
  @version "0.1.0"

  def project do
    [
      app: :dg,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      preferred_cli_env: [
        docs: :docs,
        "hex.publish": :docs
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:abnf_parsec, "~> 1.2", runtime: false},
      {:ex_doc, ">= 0.0.0", only: :docs}
    ]
  end

  defp package do
    [
      description: "Elixir wrapper of `:digraph` with a pinch of protocols and sigils",
      licenses: ["MIT"],
      maintainers: ["Po Chen"],
      links: %{
        Changelog: "https://hexdocs.pm/dg/changelog.html",
        GitHub: @source_url
      }
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md": [],
        LICENSE: [title: "License"],
        "README.md": [title: "Overview"]
      ],
      assets: "assets",
      main: "readme",
      canonical: "http://hexdocs.pm/dg",
      homepage_url: @source_url,
      source_url: @source_url,
      source_ref: "v#{@version}"
    ]
  end
end
