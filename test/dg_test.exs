defmodule DG.Test do
  use ExUnit.Case
  doctest DG
  doctest DG.Sigil

  setup do
    {:ok, dg: DG.new()}
  end

  describe "inspect" do
    test "disjoint", %{dg: dg} do
      DG.add_vertex(dg, 1)

      assert inspect(dg) ==
               String.trim("""
               graph LR
                   1
               """)
    end

    test "direction", %{dg: dg} do
      DG.add_vertex(dg, 1)
      dg = DG.options(dg, direction: "TB")

      assert inspect(dg) ==
               String.trim("""
               graph TB
                   1
               """)
    end

    test "vertex with label", %{dg: dg} do
      DG.add_vertex(dg, 2, "two")

      assert inspect(dg) ==
               String.trim("""
               graph LR
                   2[two]
               """)
    end

    test "arrow", %{dg: dg} do
      DG.add_vertex(dg, 1)
      DG.add_vertex(dg, 2)
      DG.add_edge(dg, 1, 2)

      assert inspect(dg) ==
               String.trim("""
               graph LR
                   1-->2
               """)
    end

    test "arrow with label", %{dg: dg} do
      DG.add_vertex(dg, 1)
      DG.add_vertex(dg, 2)
      DG.add_edge(dg, 1, 2, "one to two")

      assert inspect(dg) ==
               String.trim("""
               graph LR
                   1--one to two-->2
               """)
    end

    test "labels", %{dg: dg} do
      DG.add_vertex(dg, 1)
      DG.add_vertex(dg, 2, "two")
      DG.add_edge(dg, 1, 2, "one to two")

      assert inspect(dg) ==
               String.trim("""
               graph LR
                   1--one to two-->2[two]
               """)
    end
  end

  describe "collectable" do
    test "add vertices", %{dg: dg} do
      ~w(a b c d e) |> Enum.map(&{:vertex, &1}) |> Enum.into(dg)
      assert length(DG.vertices(dg)) == 5
    end

    test "add vertices with labels", %{dg: dg} do
      ~w(a b c d e) |> Enum.map(&{:vertex, &1, "HI #{&1}"}) |> Enum.into(dg)
      assert length(DG.vertices(dg)) == 5
      assert {"a", "HI a"} = DG.vertex(dg, "a")
    end

    test "add edges", %{dg: dg} do
      ~w(a b c d e) |> Enum.map(&{:vertex, &1}) |> Enum.into(dg)

      ~w(a b c d e)
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [f, t] -> {:edge, f, t} end)
      |> Enum.into(dg)

      assert length(DG.edges(dg)) == 4
    end

    test "add edges with labels", %{dg: dg} do
      ~w(a b c d e) |> Enum.map(&{:vertex, &1}) |> Enum.into(dg)

      ~w(a b c d e)
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [f, t] -> {:edge, f, t, "#{f} -> #{t}"} end)
      |> Enum.into(dg)

      assert length(DG.edges(dg)) == 4
      assert {_, "a", "b", "a -> b"} = DG.edge(dg, List.first(DG.edges(dg, "a")))
    end
  end

  describe "subgraph" do
    test "returns a DG" do
      dg = DG.new(test: true)
      ~w(a b c d e) |> Enum.map(&{:vertex, &1}) |> Enum.into(dg)

      assert %DG{} = DG.subgraph(dg, ~w(a b c))
    end

    test "handles digraph options" do
      dg = DG.new(test: true)
      ~w(a b c) |> Enum.map(&{:vertex, &1}) |> Enum.into(dg)

      label = "a -> b"
      Enum.into([{:edge, "a", "b", label}], dg)

      subgraph = DG.subgraph(dg, ~w(a b), digraph_opts: [keep_labels: true])

      assert {_, "a", "b", ^label} = DG.edge(subgraph, List.first(DG.edges(dg, "a")))
    end
  end

  describe "sigil" do
    import DG.Sigil

    test "ingetration" do
      dg = ~g"""
      graph LR
      a[aaaaa]
        b[bb bb bb]
        1-->          2
        3[three] --   1 2 3    --> 4[four]
        c        -->a
      """

      text = inspect(dg)

      assert text =~ "graph LR"
      assert text =~ "3[three]--1 2 3-->4[four]"
      assert text =~ "1-->2"
      assert text =~ "a[aaaaa]"
      assert text =~ "b[bb bb bb]"
    end

    test "interpolation" do
      label = "1 2 3"

      dg = ~g"""
      graph LR
        a -- #{label} --> b
      """

      text = inspect(dg)
      assert text =~ "a--1 2 3-->b"
    end
  end
end
