defmodule AdventOfCode.Day01Test do
  use ExUnit.Case

  import AdventOfCode.Day01

  test "part1" do
    input = "199\n200\n208\n210\n200\n207\n240\n269\n260\n263"
    result = part1(input)

    assert result == 7
  end

  test "part2" do
    input = "199\n200\n208\n210\n200\n207\n240\n269\n260\n263"
    result = part2(input)

    assert result == 5
  end
end
