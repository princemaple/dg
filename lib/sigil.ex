defmodule DG.Sigil do
  @moduledoc """
  Sigils that parse `mermaid.js` format flowchart into `DG`

      iex> import DG.Sigil
      ...> dg = ~G"\""
      ...> graph LR
      ...>   a[some label]
      ...>   b[other label]
      ...>   1-->2
      ...>   3[three] -- three to four --> 4[four]
      ...>   a --> b
      ...> "\""
      iex> DG.vertex(dg, "a")
      {"a", "some label"}
      iex> Enum.sort(DG.vertices(dg))
      ["1", "2", "3", "4", "a", "b"]
      iex> length(DG.edges(dg))
      3
  """

  use AbnfParsec,
    abnf: """
    wsp = %x20 / %x09
    lwsp = *(wsp / LF / CRLF)
    direction = "TB" / "TD" / "LR"
    type = "flowchart" / "graph"
    label = 1*(ALPHA / DIGIT / %x20)
    square-brace-open = "["
    square-brace-close = "]"
    vertex-id = 1*(ALPHA / DIGIT)
    vertex = vertex-id [square-brace-open label square-brace-close]
    edge = vertex *wsp ("-->" / "--" label "-->") *wsp vertex
    vertex-or-edge = [lwsp] (edge / vertex)
    graph = lwsp type 1*wsp direction lwsp *vertex-or-edge
    """,
    parse: :graph,
    unbox: ["vertex-or-edge", "vertex-id"],
    ignore: ["wsp", "lwsp", "square-brace-open", "square-brace-close"],
    unwrap: ["type", "direction", "label"],
    transform: %{
      "vertex-id" => {:reduce, {List, :to_string, []}},
      "label" => [{:reduce, {List, :to_string, []}}, {:map, {String, :trim, []}}]
    }

  defp unwrap_vertex({:vertex, [v]}) do
    {:vertex, v}
  end

  defp unwrap_vertex({:vertex, [v, label: label]}) do
    {:vertex, v, label}
  end

  defp extract_vertex({:vertex, [v | _]}), do: v
  defp extract_vertex({:vertex, v, _label}), do: v
  defp extract_vertex({:vertex, v}), do: v

  defp extract_edge({:edge, v1, v2, _label}), do: {v1, v2}
  defp extract_edge({:edge, v1, v2}), do: {v1, v2}

  defp gen(string) do
    {:ok, [graph: [{:type, _type}, {:direction, direction} | content]], _, _, _, _} =
      parse(string)

    vertices =
      content
      |> Enum.flat_map(fn
        {:vertex, _} = v ->
          [unwrap_vertex(v)]

        {:edge, [v1, "-->", v2]} ->
          [unwrap_vertex(v1), unwrap_vertex(v2)]

        {:edge, [v1, "--", _label, "-->", v2]} ->
          [unwrap_vertex(v1), unwrap_vertex(v2)]
      end)
      |> Enum.uniq_by(&extract_vertex/1)
      |> Macro.escape()

    edges =
      content
      |> Enum.filter(fn
        {:edge, _} -> true
        _ -> false
      end)
      |> Enum.map(fn
        {:edge, [v1, "-->", v2]} ->
          {:edge, extract_vertex(v1), extract_vertex(v2)}

        {:edge, [v1, "--", {:label, label}, "-->", v2]} ->
          {:edge, extract_vertex(v1), extract_vertex(v2), label}
      end)
      |> Enum.uniq_by(&extract_edge/1)
      |> Macro.escape()

    quote do
      DG.new(unquote(vertices), unquote(edges), direction: unquote(direction))
    end
  end

  defmacro sigil_g({:<<>>, _, [string]}, _opts), do: gen(string)
  defmacro sigil_G({:<<>>, _, [string]}, _opts), do: gen(string)
end
