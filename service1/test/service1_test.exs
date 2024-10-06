defmodule Service1Test do
  use ExUnit.Case
  doctest Service1

  test "greets the world" do
    assert Service1.hello() == :world
  end
end
