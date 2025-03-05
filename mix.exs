defmodule DG.MixProject do
  use Mix.Project

  @source_url "https://github.com/princemaple/dg"
  @version "0.4.1"

  def project do
    [
      app: :dg,
      version: @version,
      elixir: "~> 1.12",
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
      {:abnf_parsec, "~> 2.0", runtime: false},
      {:libgraph, ">= 0.0.0", optional: true},
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
      source_ref: "v#{@version}",
      before_closing_body_tag: &before_closing_body_tag/1
    ]
  end

  defp before_closing_body_tag(:html) do
    """
    <script src="https://unpkg.com/mermaid@9.1.7/dist/mermaid.min.js"></script>
    <script>
      document.addEventListener("DOMContentLoaded", function () {
        mermaid.initialize({ startOnLoad: false });
        let id = 0;
        for (const codeEl of document.querySelectorAll("pre code.mermaid")) {
          const preEl = codeEl.parentElement;
          const graphDefinition = codeEl.textContent;
          const graphEl = document.createElement("div");
          const graphId = "mermaid-graph-" + id++;
          mermaid.render(graphId, graphDefinition, function (svgSource, bindListeners) {
            graphEl.innerHTML = svgSource;
            bindListeners && bindListeners(graphEl);
            preEl.insertAdjacentElement("afterend", graphEl);
            preEl.remove();
          });
        }
      });
    </script>
    """
  end

  defp before_closing_body_tag(_), do: ""
end
