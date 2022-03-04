defmodule AdventOfCode.Day17 do
  def part1(args) do
    args
    |> parse_input()
    |> find_possible_trajectories()
    |> Enum.map(fn {{_, _}, highest_y} -> highest_y end)
    |> Enum.max()
  end

  def part2(args) do
    args
    |> parse_input()
    |> find_possible_trajectories()
    |> Enum.count()
  end

  def parse_input(input) do
    input
    |> String.trim()
    |> parse_target_area()
  end

  def parse_target_area(string) do
    split = String.split(string)

    [x1, x2] =
      split
      |> Enum.at(2)
      |> String.trim(",")
      |> String.split("=")
      |> Enum.at(1)
      |> String.split("..")
      |> Enum.map(&String.to_integer/1)

    [y1, y2] =
      split
      |> Enum.at(3)
      |> String.split("=")
      |> Enum.at(1)
      |> String.split("..")
      |> Enum.map(&String.to_integer/1)

    {x1, x2, y1, y2}
  end

  def find_possible_trajectories({x1, x2, y1, y2}) do
    # Just brute force it, using reasonable guesses at possible x and y ranges
    # 0 is minimum possible x, and x2 is the maxmimum possible x,
    # y1 is the minimum possible y, and -y1 is maximum possible y (since y1 is negative to start)
    for x <- -0..x2, y <- y1..-y1 do
      {x, y}
    end
    |> Enum.map(fn {x, y} ->
      process_trajectory({x1, x2, y1, y2}, {x, y}, {0, 0}, x, y, 0)
    end)
    |> Enum.filter(&(elem(&1, 0) == :success))
    |> Enum.map(fn {:success, {x, y}, highest_y} -> {{x, y}, highest_y} end)
  end

  def process_trajectory({x1, x2, y1, y2}, {x, y}, {px, py}, vel_x, vel_y, highest_y) do
    cond do
      px > x2 ->
        {:fail}

      py < y1 ->
        {:fail}

      px >= x1 and px <= x2 and py <= y2 and py >= y1 ->
        {:success, {x, y}, highest_y}

      true ->
        {px, py, vel_x, vel_y} = process_step({px, py}, vel_x, vel_y)
        highest_y = Enum.max([highest_y, py])
        process_trajectory({x1, x2, y1, y2}, {x, y}, {px, py}, vel_x, vel_y, highest_y)
    end
  end

  def process_step({x, y}, vel_x, vel_y) do
    x = x + vel_x
    y = y + vel_y

    vel_x =
      cond do
        vel_x == 0 -> 0
        vel_x > 0 -> vel_x - 1
        true -> vel_x + 1
      end

    vel_y = vel_y - 1
    {x, y, vel_x, vel_y}
  end
end
