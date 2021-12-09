defmodule AdventOfCode.Day09 do

  def part1(args) do
    args
    |> parse_input()
    |> find_lows()
    |> Enum.map(fn {_, _, curr} -> curr + 1 end)
    |> Enum.sum()
  end

  def part2(args) do
    {grid, width, height} = parse_input(args)
    lows = find_lows({grid, width, height})
    basins = Enum.map(lows, fn {x, y, _} ->
      {total, _} = basin_size(x, y, grid, MapSet.new([{x, y}]))
      total
    end)
    basins
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.take(3)
    |> Enum.product()
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
    |> to_grid()
  end

  def to_grid(input) do
    width = Enum.count(Enum.at(input, 0))
    height = Enum.count(input)
    grid = for col <- 0..width-1, row <- 0..height-1, into: %{}, do: {{col, row}, String.to_integer(Enum.at(Enum.at(input, row), col))}
    {grid, width, height}
  end

  def find_lows({grid, width, height}) do find_lows(0, 0, width, height, grid) end
  def find_lows(_x, y, _width, height, _grid) when y == height, do: []
  def find_lows(x, y, width, height, grid) do
    curr = Map.get(grid, {x, y})
    is_low_point =
      (x == 0 or Map.get(grid, {x-1, y}) > curr) and
      (y == 0 or Map.get(grid, {x, y-1}) > curr) and
      (x == width-1 or Map.get(grid, {x+1, y}) > curr) and
      (y == height-1 or Map.get(grid, {x, y+1}) > curr)
    new_x = if x == width do 0 else x+1 end
    new_y = if new_x == 0 do y+1 else y end
    find_lows(new_x, new_y, width, height, grid) ++ if is_low_point do [{x, y, curr}] else [] end
  end

  def basin_size(x, y, grid, visited) do
    case Map.get(grid, {x, y}) do
      9 -> {0, visited} # Reached a peak in the grid
      nil -> {0, visited} # Went off the edge of the grid
      _ -> # Count current square, and check adjacent
        {count_left, visited} = if MapSet.member?(visited, {x-1, y}) do {0, visited} else basin_size(x-1, y, grid, MapSet.put(visited, {x-1, y})) end
        {count_right, visited} = if MapSet.member?(visited, {x+1, y}) do {0, visited} else basin_size(x+1, y, grid, MapSet.put(visited, {x+1, y})) end
        {count_up, visited} = if MapSet.member?(visited, {x, y-1}) do {0, visited} else basin_size(x, y-1, grid, MapSet.put(visited, {x, y-1})) end
        {count_down, visited} = if MapSet.member?(visited, {x, y+1}) do {0, visited} else basin_size(x, y+1, grid, MapSet.put(visited, {x, y+1})) end
        {count_left + count_right + count_up + count_down + 1, visited}
    end
  end

end
