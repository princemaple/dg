defmodule DG.Sigil do
  use AbnfParsec,
    abnf: """
    wsp = %x20 / %x09
    lwsp = *(wsp / LF / CR LF)
    direction = "TB" / "TD" / "LR"
    type = "flowchart" / "graph"
    vertex = 1*(ALPHA / DIGIT)
    label = 1*(ALPHA / DIGIT / wsp)
    edge = vertex *wsp ("-->" / "--" label "-->") *wsp vertex
    vertex-or-edge = [lwsp] (edge / vertex)
    graph = lwsp type 1*wsp direction lwsp *vertex-or-edge
    """,
    parse: :graph,
    unbox: ["vertex-or-edge"],
    ignore: ["wsp", "lwsp"],
    unwrap: ["type", "direction", "vertex", "label"],
    transform: %{
      "vertex" => {:reduce, {List, :to_string, []}},
      "label" => {:reduce, {List, :to_string, []}}
    }

  defmacro sigil_g({:<<>>, _, [string]}, _opts) do
    {:ok, [graph: [{:type, _type}, {:direction, direction} | content]], _, _, _, _} =
      parse(string)

    vertices =
      content
      |> Enum.filter(fn
        {:vertex, _v} -> true
        {:vertex, _v, _label} -> true
        {:edge, [_v1, "-->", _v2]} -> true
        {:edge, [_v1, "--", _label, "-->", _v2]} -> true
        _ -> false
      end)
      |> Enum.flat_map(fn
        {:vertex, v} ->
          [{:vertex, v}]

        {:vertex, v, label} ->
          [{:vertex, v, label}]

        {:edge, [{:vertex, v1}, "-->", {:vertex, v2}]} ->
          [{:vertex, v1}, {:vertex, v2}]

        {:edge, [{:vertex, v1}, "--", _label, "-->", {:vertex, v2}]} ->
          [{:vertex, v1}, {:vertex, v2}]
      end)
      |> Macro.escape()

    edges =
      content
      |> Enum.filter(fn
        {:edge, [_v1, "-->", _v2]} -> true
        {:edge, [_v1, "--", _label, "-->", _v2]} -> true
        _ -> false
      end)
      |> Enum.map(fn
        {:edge, [{:vertex, v1}, "-->", {:vertex, v2}]} ->
          {:edge, v1, v2}

        {:edge, [{:vertex, v1}, "--", {:label, label}, "-->", {:vertex, v2}]} ->
          {:edge, v1, v2, label}
      end)
      |> Macro.escape()

    quote do
      DG.new(unquote(vertices), unquote(edges), direction: unquote(direction))
    end
  end
end
