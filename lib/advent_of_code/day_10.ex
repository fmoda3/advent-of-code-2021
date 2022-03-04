defmodule AdventOfCode.Day10 do
  def part1(args) do
    args
    |> parse_input()
    |> Enum.map(&solve_line/1)
    |> Enum.filter(fn {type, _} -> type == :corrupt end)
    |> Enum.map(fn {_, x} -> x end)
    |> Enum.map(&val_of_corrupt_char/1)
    |> Enum.sum()
  end

  def part2(args) do
    results =
      args
      |> parse_input()
      |> Enum.map(&solve_line/1)
      |> Enum.filter(fn {type, _} -> type == :incomplete end)
      |> Enum.map(fn {_, x} -> x end)
      |> Enum.map(fn x ->
        Enum.reduce(x, 0, fn x, acc ->
          acc * 5 + val_of_incomplete_char(x)
        end)
      end)
      |> Enum.sort()

    Enum.at(results, div(Enum.count(results) - 1, 2))
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  # Entry to recursive function to initialize stack
  def solve_line(line), do: solve_line(line, [])
  # If we reach here, the line is now empty, and so we must just be incomplete
  # The stack will contain the incomplete chars, already in order
  def solve_line([], stack), do: {:incomplete, stack}
  # Iterate through line, looking for corrupt chars
  # For opening chars, append closing char to stack, and recurse
  def solve_line(["{" | t], stack), do: solve_line(t, ["}"] ++ stack)
  def solve_line(["[" | t], stack), do: solve_line(t, ["]"] ++ stack)
  def solve_line(["(" | t], stack), do: solve_line(t, [")"] ++ stack)
  def solve_line(["<" | t], stack), do: solve_line(t, [">"] ++ stack)
  # For closing chars, check if it matches the head of the stack
  def solve_line(["}" | t], ["}" | ts]), do: solve_line(t, ts)
  def solve_line(["]" | t], ["]" | ts]), do: solve_line(t, ts)
  def solve_line([")" | t], [")" | ts]), do: solve_line(t, ts)
  def solve_line([">" | t], [">" | ts]), do: solve_line(t, ts)
  # If none of the above match, we must have a corrupt char
  def solve_line(["}" | _], _), do: {:corrupt, "}"}
  def solve_line(["]" | _], _), do: {:corrupt, "]"}
  def solve_line([")" | _], _), do: {:corrupt, ")"}
  def solve_line([">" | _], _), do: {:corrupt, ">"}

  def val_of_corrupt_char(char) do
    case char do
      ")" -> 3
      "]" -> 57
      "}" -> 1197
      ">" -> 25137
    end
  end

  def val_of_incomplete_char(char) do
    case char do
      ")" -> 1
      "]" -> 2
      "}" -> 3
      ">" -> 4
    end
  end
end
