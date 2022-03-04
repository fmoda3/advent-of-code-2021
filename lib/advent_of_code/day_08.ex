defmodule AdventOfCode.Day08 do
  defmodule Entry do
    @enforce_keys [:input, :output]
    defstruct [:input, :output]
  end

  def part1(args) do
    args
    |> parse_input()
    |> Enum.map(fn x -> x.output end)
    |> Enum.concat()
    |> Enum.map(&categorize_signal_part_1/1)
    |> Enum.count(fn x -> x != nil end)
  end

  def part2(args) do
    args
    |> parse_input()
    |> Enum.map(&solve_line/1)
    |> Enum.sum()
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    [input_string, output_string] = String.split(line, "|", trim: true)
    input_list = String.split(input_string, " ", trim: true)
    output_list = String.split(output_string, " ", trim: true)
    input_list = Enum.map(input_list, fn x -> Enum.join(Enum.sort(String.graphemes(x))) end)
    output_list = Enum.map(output_list, fn x -> Enum.join(Enum.sort(String.graphemes(x))) end)
    %Entry{input: input_list, output: output_list}
  end

  def categorize_signal_part_1(signal) do
    len = String.length(signal)

    cond do
      len == 2 -> :one
      len == 3 -> :seven
      len == 4 -> :four
      len == 7 -> :eight
      true -> nil
    end
  end

  def solve_line(entry) do
    line = Enum.concat([entry.input, entry.output])
    line = Enum.map(line, &String.graphemes/1)
    # We know how to solve 1, 4, 7, and 8
    one =
      line
      |> Enum.filter(fn x -> Enum.count(x) == 2 end)
      |> List.first()

    four =
      line
      |> Enum.filter(fn x -> Enum.count(x) == 4 end)
      |> List.first()

    seven =
      line
      |> Enum.filter(fn x -> Enum.count(x) == 3 end)
      |> List.first()

    eight =
      line
      |> Enum.filter(fn x -> Enum.count(x) == 7 end)
      |> List.first()

    # Top is solved as the only segment 7 has that 1 doesn't
    top = seven -- one

    # 9 must be the value that has one remaining segment when the segments from 7 and 4 are removed
    nine =
      line
      |> Enum.filter(fn x -> Enum.count(x) == 6 end)
      |> Enum.filter(fn x -> Enum.count((x -- seven) -- four) == 1 end)
      |> Enum.uniq()
      |> List.first()

    # Bottom is now solved, the only segment 9 has that 7 and 4 don't
    bottom = (nine -- seven) -- four
    # Bottom left must be the only segment 8 has that 9 doesn't
    bottom_left = eight -- nine

    # So, both 3 and 5 have one segment that 9 doesn't
    # But, 3 would have 3 remaining segments when removing the segments from 1
    # And, 5 would have 4 remaining segments when removing the segments from 1
    three =
      line
      |> Enum.filter(fn x -> Enum.count(x) == 5 end)
      |> Enum.filter(fn x -> Enum.count(nine -- x) == 1 and Enum.count(x -- one) == 3 end)
      |> Enum.uniq()
      |> List.first()

    five =
      line
      |> Enum.filter(fn x -> Enum.count(x) == 5 end)
      |> Enum.filter(fn x -> Enum.count(nine -- x) == 1 and Enum.count(x -- one) == 4 end)
      |> Enum.uniq()
      |> List.first()

    # We have enough info for the rest
    # Top left is the only segment nine has that 3 doesn't
    top_left = nine -- three
    # Top right is the only segment nine has that 5 doesn't
    top_right = nine -- five
    # Bottom right is just the other segment from 1 that isn't top right
    bottom_right = one -- top_right
    # Middle is 8 without the rest of the segments
    middle = eight -- (top ++ top_left ++ top_right ++ bottom_left ++ bottom_right ++ bottom)

    # Figure out the characters for the three remaining unsolved numbers
    zero = Enum.sort(top ++ top_left ++ top_right ++ bottom_left ++ bottom_right ++ bottom)
    two = Enum.sort(top ++ top_right ++ middle ++ bottom_left ++ bottom)
    six = Enum.sort(top ++ top_left ++ middle ++ bottom_left ++ bottom_right ++ bottom)

    zero = Enum.join(zero)
    one = Enum.join(one)
    two = Enum.join(two)
    three = Enum.join(three)
    four = Enum.join(four)
    five = Enum.join(five)
    six = Enum.join(six)
    seven = Enum.join(seven)
    eight = Enum.join(eight)
    nine = Enum.join(nine)

    # Convert output to a number
    entry.output
    |> Enum.map(fn x ->
      case x do
        ^zero -> "0"
        ^one -> "1"
        ^two -> "2"
        ^three -> "3"
        ^four -> "4"
        ^five -> "5"
        ^six -> "6"
        ^seven -> "7"
        ^eight -> "8"
        ^nine -> "9"
      end
    end)
    |> Enum.join()
    |> String.to_integer()
  end
end
