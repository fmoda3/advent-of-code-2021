defmodule AdventOfCode.Day25 do

  def part1(args) do
    args
    |> parse_input()
    |> run_steps()
    |> (fn {_, count} -> count end).()
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
    grid = for col <- 0..width-1, row <- 0..height-1, into: %{}, do: {{col, row}, Enum.at(Enum.at(input, row), col)}
    {grid, width, height}
  end

  def run_steps({grid, width, height}), do: run_steps({grid, width, height}, 0)
  def run_steps({grid, width, height}, count) do
    {grid, steps} = Enum.reduce(grid, {grid, 0}, fn {{col, row}, char}, {new_grid, steps} ->
      next_col = rem(col+1, width)
      next_char = Map.get(grid, {next_col, row})
      case {char, next_char} do
        {">", "."} ->
          new_grid = new_grid
          |> Map.put({col, row}, ".")
          |> Map.put({next_col, row}, ">")
          {new_grid, steps+1}
        _ -> {new_grid, steps}
      end
    end)
    {grid, steps} = Enum.reduce(grid, {grid, steps}, fn {{col, row}, char}, {new_grid, steps} ->
      next_row = rem(row+1, height)
      next_char = Map.get(grid, {col, next_row})
      case {char, next_char} do
        {"v", "."} ->
          new_grid = new_grid
          |> Map.put({col, row}, ".")
          |> Map.put({col, next_row}, "v")
          {new_grid, steps+1}
        _ -> {new_grid, steps}
      end
    end)
    case steps do
      0 -> {grid, count+1}
      _ -> run_steps({grid, width, height}, count+1)
    end
  end

end
