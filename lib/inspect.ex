defimpl Inspect, for: DG do
  import Inspect.Algebra

  def inspect(%DG{dg: dg, opts: opts}, _opts) do
    vertices = :digraph.vertices(dg)

    direction = Keyword.get(opts, :direction, "LR")

    edges =
      vertices
      |> Enum.flat_map(fn v ->
        case {:digraph.out_edges(dg, v), :digraph.in_edges(dg, v)} do
          {[], []} ->
            [inspect_node(dg, v)]

          {out_edges, _} ->
            Enum.map(out_edges, fn e ->
              {_e, ^v, n, label} = :digraph.edge(dg, e)

              case label do
                [] ->
                  concat([inspect_node(dg, v), "-->", inspect_node(dg, n)])

                _ ->
                  concat([inspect_node(dg, v), "--", inspect_term(label), "-->", inspect_node(dg, n)])
              end
            end)
        end
      end)

    content =
      edges
      |> Enum.intersperse(line())
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
      {^v, l} -> [prefix, "[", inspect_term(l), "]"]
    end
    |> concat
  end

  defp inspect_term(term) when is_binary(term), do: term
  defp inspect_term(term), do: inspect(term)
end
