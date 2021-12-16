defmodule AdventOfCode.Day16Test do
  use ExUnit.Case

  import AdventOfCode.Day16

  test "part1_1" do
    input = "8A004A801A8002F478"
    result = part1(input)

    assert result == 16
  end

  test "part1_2" do
    input = "620080001611562C8802118E34"
    result = part1(input)

    assert result == 12
  end

  test "part1_3" do
    input = "C0015000016115A2E0802F182340"
    result = part1(input)

    assert result == 23
  end

  test "part1_4" do
    input = "A0016C880162017C3686B18A3D4780"
    result = part1(input)

    assert result == 31
  end

  test "part2_1" do
    input = "C200B40A82"
    result = part2(input)

    assert result == 3
  end

  test "part2_2" do
    input = "04005AC33890"
    result = part2(input)

    assert result == 54
  end

  test "part2_3" do
    input = "880086C3E88112"
    result = part2(input)

    assert result == 7
  end

  test "part2_4" do
    input = "CE00C43D881120"
    result = part2(input)

    assert result == 9
  end

  test "part2_5" do
    input = "D8005AC2A8F0"
    result = part2(input)

    assert result == 1
  end

  test "part2_6" do
    input = "F600BC2D8F"
    result = part2(input)

    assert result == 0
  end

  test "part2_7" do
    input = "9C005AC2F8F0"
    result = part2(input)

    assert result == 0
  end

  test "part2_8" do
    input = "9C0141080250320F1802104A08"
    result = part2(input)

    assert result == 1
  end
end
