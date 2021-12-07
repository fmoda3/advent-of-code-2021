defmodule AdventOfCode.Day07 do

  def part1(args) do
    args
    |> parse_input()
    |> least_sum_difference()
  end

  def part2(args) do
    args
    |> parse_input()
    |> least_sum_difference_2()
  end

  def parse_input(input) do
    input
    |> String.trim()
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def median(nums) do
    middle_index = nums
    |> Enum.count()
    |> div(2)
    nums
    |> Enum.sort()
    |> Enum.at(middle_index)
  end

  def least_sum_difference(nums) do
    best_position = median(nums)
    calculate_fuel(nums, best_position)
  end

  def calculate_fuel(nums, pos) do
    Enum.reduce(nums, 0, fn x, acc -> acc + abs(pos - x) end)
  end

  # We will need to test both positions near the average
  def average(nums) do
    avg = Enum.sum(nums) / Enum.count(nums)
    {floor(avg), ceil(avg)}
  end

  def least_sum_difference_2(nums) do
    {low_position, high_position} = average(nums)
    Enum.min([calculate_real_fuel(nums, low_position), calculate_real_fuel(nums, high_position)])
  end

  def calculate_real_fuel(nums, pos) do
    Enum.reduce(nums, 0, fn x, acc ->
      diff = abs(pos - x)
      nth_triangle = div(diff*diff + diff, 2)
      acc + nth_triangle
    end)
  end

end
