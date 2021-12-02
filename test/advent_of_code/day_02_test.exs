defmodule AdventOfCode.Day02Test do
  use ExUnit.Case

  import AdventOfCode.Day02

  test "part1" do
    input = "forward 5\ndown 5\nforward 8\nup 3\ndown 8\nforward 2"
    result = part1(input)

    assert result == 150
  end

  test "part2" do
    input = "forward 5\ndown 5\nforward 8\nup 3\ndown 8\nforward 2"
    result = part2(input)

    assert result == 900
  end
end
