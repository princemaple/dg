defimpl Inspect, for: DG do
  import Inspect.Algebra

  def inspect(%DG{dg: dg, opts: opts}, _opts) do
    vertices = :digraph.vertices(dg)

    direction = Keyword.get(opts, :direction, "LR")

    content =
      vertices
      |> Enum.map(fn v ->
        case {:digraph.out_edges(dg, v), :digraph.in_edges(dg, v)} do
          {[], []} ->
            [inspect_node(dg, v)]

          {out_edges, _} ->
            out_edges
            |> Enum.map(&:digraph.edge(dg, &1))
            |> Enum.map(fn
              {_e, ^v, n, []} ->
                [inspect_node(dg, v), "-->", inspect_node(dg, n)]

              {_e, ^v, n, label} ->
                [inspect_node(dg, v), "--", label, "-->", inspect_node(dg, n)]
            end)
            |> Enum.intersperse([line()])
        end
      end)
      |> Enum.reject(&match?([], &1))
      |> Enum.intersperse([line()])
      |> List.flatten()
      |> concat()

    concat([
      "graph #{direction}",
      nest(
        concat([
          line(),
          content
        ]),
        4
      )
    ])
  end

  defp inspect_node(dg, string) when is_binary(string), do: label(dg, string, string)
  defp inspect_node(dg, other), do: label(dg, other, inspect(other))

  defp label(dg, v, prefix) do
    case :digraph.vertex(dg, v) do
      {^v, []} -> [prefix]
      {^v, l} -> [prefix, "[", l, "]"]
    end
    |> concat
  end
end
