defimpl Collectable, for: DG do
  def into(%DG{} = dg) do
    {dg, &push/2}
  end

  defp push(%DG{} = g, {:cont, {:vertex, v}}) do
    DG.add_vertex(g, v)
    g
  end

  defp push(%DG{} = g, {:cont, {:vertex, v, label}}) do
    DG.add_vertex(g, v, label)
    g
  end

  defp push(%DG{} = g, {:cont, {:edge, v1, v2}}) do
    DG.add_edge(g, v1, v2)
    g
  end

  defp push(%DG{} = g, {:cont, {:edge, v1, v2, label}}) do
    DG.add_edge(g, v1, v2, label)
    g
  end

  defp push(g, :done), do: g
  defp push(_g, :halt), do: :ok
end
