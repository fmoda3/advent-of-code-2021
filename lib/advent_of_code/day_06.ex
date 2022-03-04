defmodule AdventOfCode.Day06 do
  def part1(args) do
    args
    |> parse_input()
    |> simulate_rounds(80)
    |> Enum.reduce(0, fn {_, val}, count -> val + count end)
  end

  def part2(args) do
    args
    |> parse_input()
    |> simulate_rounds(256)
    |> Enum.reduce(0, fn {_, val}, count -> val + count end)
  end

  def parse_input(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce(%{}, fn x, acc ->
      Map.put(acc, x, Map.get(acc, x, 0) + 1)
    end)
  end

  def simulate_rounds(fish, 0), do: fish

  def simulate_rounds(fish, num_rounds) do
    new_fish = Map.get(fish, 0, 0)
    fish = Map.put(fish, 0, Map.get(fish, 1, 0))
    fish = Map.put(fish, 1, Map.get(fish, 2, 0))
    fish = Map.put(fish, 2, Map.get(fish, 3, 0))
    fish = Map.put(fish, 3, Map.get(fish, 4, 0))
    fish = Map.put(fish, 4, Map.get(fish, 5, 0))
    fish = Map.put(fish, 5, Map.get(fish, 6, 0))
    fish = Map.put(fish, 6, Map.get(fish, 7, 0) + new_fish)
    fish = Map.put(fish, 7, Map.get(fish, 8, 0))
    fish = Map.put(fish, 8, new_fish)
    simulate_rounds(fish, num_rounds - 1)
  end
end
