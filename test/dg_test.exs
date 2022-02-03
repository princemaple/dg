defmodule DG.Test do
  use ExUnit.Case
  doctest DG

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
end
