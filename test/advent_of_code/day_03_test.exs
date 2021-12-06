defmodule AdventOfCode.Day03Test do
  use ExUnit.Case

  import AdventOfCode.Day03

  test "part1" do
    input = "00100\n11110\n10110\n10111\n10101\n01111\n00111\n11100\n10000\n11001\n00010\n01010"
    result = part1(input)

    assert result == 198
  end

  test "part2" do
    input = "00100\n11110\n10110\n10111\n10101\n01111\n00111\n11100\n10000\n11001\n00010\n01010"
    result = part2(input)

    assert result == 230
  end
end
