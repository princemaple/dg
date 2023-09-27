defmodule DG do
  @external_resource "README.md"
  @moduledoc File.read!("README.md") |> String.split("<!-- DOC -->") |> List.last()

  defstruct dg: nil, opts: []

  def new(opts \\ []) do
    {digraph_opts, opts} = Keyword.pop(opts, :digraph_opts, [])
    %__MODULE__{dg: :digraph.new(digraph_opts), opts: opts}
  end

  def new(vertices, opts) do
    Enum.into(vertices, DG.new(opts))
  end

  def new(vertices, edges, opts) do
    Enum.into(edges, new(vertices, opts))
  end

  def options(%__MODULE__{opts: opts}) do
    opts
  end

  def options(%__MODULE__{opts: opts} = dg, new_opts) do
    %{dg | opts: Keyword.merge(opts, new_opts)}
  end

  def add_edge(%__MODULE__{dg: dg}, v1, v2) do
    :digraph.add_edge(dg, v1, v2)
  end

  def add_edge(%__MODULE__{dg: dg}, v1, v2, label) do
    :digraph.add_edge(dg, v1, v2, label)
  end

  def add_edge(%__MODULE__{dg: dg}, e, v1, v2, label) do
    :digraph.add_edge(dg, e, v1, v2, label)
  end

  def add_vertex(%__MODULE__{dg: dg}) do
    :digraph.add_vertex(dg)
  end

  def add_vertex(%__MODULE__{dg: dg}, v) do
    :digraph.add_vertex(dg, v)
  end

  def add_vertex(%__MODULE__{dg: dg}, v, label) do
    :digraph.add_vertex(dg, v, label)
  end

  def del_edge(%__MODULE__{dg: dg}, e) do
    :digraph.del_edge(dg, e)
  end

  def del_edges(%__MODULE__{dg: dg}, edges) do
    :digraph.del_edges(dg, edges)
  end

  def del_path(%__MODULE__{dg: dg}, v1, v2) do
    :digraph.del_path(dg, v1, v2)
  end

  def del_vertex(%__MODULE__{dg: dg}, v) do
    :digraph.del_vertex(dg, v)
  end

  def del_vertices(%__MODULE__{dg: dg}, vertices) do
    :digraph.del_vertices(dg, vertices)
  end

  def delete(%__MODULE__{dg: dg}) do
    :digraph.delete(dg)
  end

  def edge(%__MODULE__{dg: dg}, e) do
    :digraph.edge(dg, e)
  end

  def edges(%__MODULE__{dg: dg}) do
    :digraph.edges(dg)
  end

  def edges(%__MODULE__{dg: dg}, v) do
    :digraph.edges(dg, v)
  end

  def get_cycle(%__MODULE__{dg: dg}, v) do
    :digraph.get_cycle(dg, v)
  end

  def get_path(%__MODULE__{dg: dg}, v1, v2) do
    :digraph.get_path(dg, v1, v2)
  end

  def get_short_cycle(%__MODULE__{dg: dg}, v) do
    :digraph.get_short_cycle(dg, v)
  end

  def get_short_path(%__MODULE__{dg: dg}, v1, v2) do
    :digraph.get_short_path(dg, v1, v2)
  end

  def in_degree(%__MODULE__{dg: dg}, v) do
    :digraph.in_degree(dg, v)
  end

  def in_edges(%__MODULE__{dg: dg}, v) do
    :digraph.in_edges(dg, v)
  end

  def in_neighbours(%__MODULE__{dg: dg}, v) do
    :digraph.in_neighbours(dg, v)
  end

  def info(%__MODULE__{dg: dg}) do
    :digraph.info(dg)
  end

  def no_edges(%__MODULE__{dg: dg}) do
    :digraph.no_edges(dg)
  end

  def no_vertices(%__MODULE__{dg: dg}) do
    :digraph.no_vertices(dg)
  end

  def out_degree(%__MODULE__{dg: dg}, v) do
    :digraph.out_degree(dg, v)
  end

  def out_edges(%__MODULE__{dg: dg}, v) do
    :digraph.out_edges(dg, v)
  end

  def out_neighbours(%__MODULE__{dg: dg}, v) do
    :digraph.out_neighbours(dg, v)
  end

  def vertex(%__MODULE__{dg: dg}, v) do
    :digraph.vertex(dg, v)
  end

  def vertices(%__MODULE__{dg: dg}) do
    :digraph.vertices(dg)
  end

  def arborescence_root(%__MODULE__{dg: dg}) do
    :digraph_utils.arborescence_root(dg)
  end

  def components(%__MODULE__{dg: dg}) do
    :digraph_utils.components(dg)
  end

  def condensation(%__MODULE__{dg: dg}) do
    :digraph_utils.condensation(dg)
  end

  def cyclic_strong_components(%__MODULE__{dg: dg}) do
    :digraph_utils.cyclic_strong_components(dg)
  end

  def is_acyclic(%__MODULE__{dg: dg}) do
    :digraph_utils.is_acyclic(dg)
  end

  def is_arborescence(%__MODULE__{dg: dg}) do
    :digraph_utils.is_arborescence(dg)
  end

  def is_tree(%__MODULE__{dg: dg}) do
    :digraph_utils.is_tree(dg)
  end

  def loop_vertices(%__MODULE__{dg: dg}) do
    :digraph_utils.loop_vertices(dg)
  end

  def postorder(%__MODULE__{dg: dg}) do
    :digraph_utils.postorder(dg)
  end

  def preorder(%__MODULE__{dg: dg}) do
    :digraph_utils.preorder(dg)
  end

  def reachable(%__MODULE__{dg: dg}, vertices) do
    :digraph_utils.reachable(vertices, dg)
  end

  def reachable_neighbours(%__MODULE__{dg: dg}, vertices) do
    :digraph_utils.reachable_neighbours(vertices, dg)
  end

  def reaching(%__MODULE__{dg: dg}, vertices) do
    :digraph_utils.reaching(vertices, dg)
  end

  def reaching_neighbours(%__MODULE__{dg: dg}, vertices) do
    :digraph_utils.reaching_neighbours(vertices, dg)
  end

  def strong_components(%__MODULE__{dg: dg}) do
    :digraph_utils.strong_components(dg)
  end

  def subgraph(%__MODULE__{dg: dg}, vertices, options \\ []) do
    {digraph_opts, opts} = Keyword.pop(options, :digraph_opts, [])
    subgraph = :digraph_utils.subgraph(dg, vertices, digraph_opts)
    %__MODULE__{dg: subgraph, opts: opts}
  end

  def topsort(%__MODULE__{dg: dg}) do
    :digraph_utils.topsort(dg)
  end

  if Code.ensure_loaded?(Graph) do
    def from({:libgraph, graph}) do
      dg = DG.new()

      graph
      |> Graph.vertices()
      |> Enum.map(&{:vertex, &1})
      |> Enum.into(dg)

      graph
      |> Graph.edges()
      |> Enum.map(fn
        %Graph.Edge{label: nil} = e ->
          {:edge, e.v1, e.v2}

        %Graph.Edge{} = e ->
          {:edge, e.v1, e.v2, e.label}
      end)
      |> Enum.into(dg)
    end
  end
end
