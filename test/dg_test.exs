defmodule DgTest do
  use ExUnit.Case
  doctest Dg

  test "greets the world" do
    assert Dg.hello() == :world
  end
end
