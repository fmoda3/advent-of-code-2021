defmodule AdventOfCode.Day12 do
  def part1(args) do
    args
    |> parse_input()
    |> find_all_paths(true)
    |> Enum.count()
  end

  def part2(args) do
    args
    |> parse_input()
    |> find_all_paths(false)
    |> Enum.count()
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "-"))
    |> to_map()
  end

  def to_map(input) do
    Enum.reduce(input, %{}, fn [first, second], map ->
      map
      |> Map.update(first, [second], &(&1 ++ [second]))
      |> Map.update(second, [first], &(&1 ++ [first]))
    end)
  end

  def is_large_cave(cave), do: cave == String.upcase(cave)

  def find_all_paths(map, has_used_small_cave) do
    find_all_paths(map, "start", ["start"], MapSet.new(["start"]), has_used_small_cave)
  end

  def find_all_paths(map, curr, curr_path, visited, has_used_small_cave) do
    Enum.reduce(Map.get(map, curr), [], fn next_segment, all_paths ->
      cond do
        # Never go back to "start"
        next_segment == "start" ->
          all_paths

        # End the recusion at "end", add current path to results
        next_segment == "end" ->
          all_paths ++ [curr_path ++ ["end"]]

        # Always allow large cave traversal
        is_large_cave(next_segment) ->
          all_paths ++
            find_all_paths(
              map,
              next_segment,
              curr_path ++ [next_segment],
              visited,
              has_used_small_cave
            )

        # Check for small cave traversal
        not MapSet.member?(visited, next_segment) ->
          all_paths ++
            find_all_paths(
              map,
              next_segment,
              curr_path ++ [next_segment],
              MapSet.put(visited, next_segment),
              has_used_small_cave
            )

        # Check for one time re-use of small cave
        not has_used_small_cave ->
          all_paths ++
            find_all_paths(map, next_segment, curr_path ++ [next_segment], visited, true)

        # No matches, can't traverse
        true ->
          all_paths
      end
    end)
  end
end
