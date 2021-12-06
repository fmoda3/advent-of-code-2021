defmodule AdventOfCode.Day05 do

  def part1(args) do
    args
    |> parse_input()
    |> Enum.filter(fn {{x1, y1}, {x2, y2}} -> x1 == x2 || y1 == y2 end)
    |> Enum.map(&expand_line/1)
    |> Enum.flat_map(fn x -> x end)
    |> Enum.reduce(%{}, fn x, acc -> 
      Map.put(acc, x, Map.get(acc, x, 0) + 1)
    end)
    |> Enum.count(fn {_, val} -> val > 1 end)
  end

  def part2(args) do
    args
    |> parse_input()
    |> Enum.map(&expand_line/1)
    |> Enum.flat_map(fn x -> x end)
    |> Enum.reduce(%{}, fn x, acc ->
      Map.put(acc, x, Map.get(acc, x, 0) + 1)
    end)
    |> Enum.count(fn {_, val} -> val > 1 end)
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    [first_coord, second_coord] = String.split(line, " -> ", trim: true)
    [x1, y1] = String.split(first_coord, ",")
    [x2, y2] = String.split(second_coord, ",")
    {{String.to_integer(x1), String.to_integer(y1)}, {String.to_integer(x2), String.to_integer(y2)}}
  end

  def expand_line({{x1, y1}, {x2, y1}}) do
    Enum.map(x1..x2, fn x -> {x, y1} end)
  end
  def expand_line({{x1, y1}, {x1, y2}}) do
    Enum.map(y1..y2, fn y -> {x1, y} end)
  end
  def expand_line({{x1, y1}, {x2, y2}}) do
    Stream.zip_with(x1..x2, y1..y2, fn x, y -> {x, y} end)
    |> Enum.to_list()
  end

end
