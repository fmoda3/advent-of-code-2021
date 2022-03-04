defmodule AdventOfCode.Day01 do
  def part1(args) do
    args
    |> parse_input()
    |> count_increasing(2)
  end

  def part2(args) do
    args
    |> parse_input()
    |> count_increasing(4)
  end

  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
  end

  # Returns list with just the first and last element
  # [0, 1, 2, 3] -> [0, 3]
  def list_ends([]), do: []
  def list_ends([h]), do: [h]
  def list_ends([h | t]), do: [h] ++ _list_ends(t)
  def _list_ends([h]), do: [h]
  def _list_ends([_ | t]), do: _list_ends(t)

  # Takes measurements and a window size
  # Counts the number of windows where the last element
  # is greater than the first in the window
  # Note that this works for part 2 without summing, because
  # A+B+C > B+C+D is the same as A > D
  def count_increasing(measurements, window_size) do
    measurements
    |> Enum.chunk_every(window_size, 1, :discard)
    |> Enum.map(&list_ends/1)
    |> Enum.filter(fn [first, second] -> second > first end)
    |> Enum.count()
  end
end
