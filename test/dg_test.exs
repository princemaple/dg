defmodule DG.Test do
  use ExUnit.Case
  doctest DG

  test "greets the world" do
    assert DG.hello() == :world
  end
end
