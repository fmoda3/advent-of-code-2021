defmodule AdventOfCode.Day25Test do
  use ExUnit.Case

  import AdventOfCode.Day25

  test "part1" do
    input = """
    v...>>.vv>
    .vv>>.vv..
    >>.>v>...v
    >>v>>.>.v.
    v>v.vv.v..
    >.>>..v...
    .vv..>.>v.
    v.v..>>v.v
    ....v..v.>
    """
    result = part1(input)

    assert result == 58
  end

end
