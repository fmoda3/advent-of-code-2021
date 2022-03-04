defmodule AdventOfCode.Day11 do
  def part1(args) do
    args
    |> parse_input()
    |> process_n_steps(0, 100)
    |> (fn {_, count} -> count end).()
  end

  def part2(args) do
    args
    |> parse_input()
    |> process_until_all_flashes(0)
    |> (fn {_, steps} -> steps end).()
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

    for col <- 0..(width - 1),
        row <- 0..(height - 1),
        into: %{},
        do: {{col, row}, String.to_integer(Enum.at(Enum.at(input, row), col))}
  end

  def process_n_steps(grid, count, 0), do: {grid, count}

  def process_n_steps(grid, count, n) do
    {g, c} = process_step(grid)
    process_n_steps(g, count + c, n - 1)
  end

  def process_until_all_flashes(grid, steps) do
    {g, _} = process_step(grid)
    done = all_flashes(g)

    if not done do
      process_until_all_flashes(g, steps + 1)
    else
      {g, steps + 1}
    end
  end

  def process_step(grid) do
    grid
    |> increase_by_one()
    |> trigger_flashes()
    |> count_flashes()
  end

  def increase_by_one(grid) do
    Enum.reduce(grid, %{}, fn {k, v}, acc ->
      Map.put(acc, k, v + 1)
    end)
  end

  def trigger_flashes(grid) do
    {new_grid, done} =
      Enum.reduce(grid, {grid, true}, fn {{col, row}, v}, {new_grid, done} ->
        # If current is over 9, then it flashes (set to 0)
        if v > 9 do
          new_grid = Map.put(new_grid, {col, row}, 0)
          {new_grid, done}
        else
          # Don't process if we are at 0 (must've flashed)
          if v != 0 do
            # Sum up all adjacent squares that will flash this sweep
            add = 0
            top_left = Map.get(grid, {col - 1, row - 1})
            add = add + if top_left != nil and top_left > 9, do: 1, else: 0
            top = Map.get(grid, {col, row - 1})
            add = add + if top != nil and top > 9, do: 1, else: 0
            top_right = Map.get(grid, {col + 1, row - 1})
            add = add + if top_right != nil and top_right > 9, do: 1, else: 0
            left = Map.get(grid, {col - 1, row})
            add = add + if left != nil and left > 9, do: 1, else: 0
            right = Map.get(grid, {col + 1, row})
            add = add + if right != nil and right > 9, do: 1, else: 0
            bottom_left = Map.get(grid, {col - 1, row + 1})
            add = add + if bottom_left != nil and bottom_left > 9, do: 1, else: 0
            bottom = Map.get(grid, {col, row + 1})
            add = add + if bottom != nil and bottom > 9, do: 1, else: 0
            bottom_right = Map.get(grid, {col + 1, row + 1})
            add = add + if bottom_right != nil and bottom_right > 9, do: 1, else: 0
            # If we found any, add them to this spot, and make sure we do another pass
            if add > 0 do
              new_grid = Map.put(new_grid, {col, row}, v + add)
              {new_grid, false}
            else
              {new_grid, done}
            end
          else
            {new_grid, done}
          end
        end
      end)

    # It's possible we have to take another sweep for this step
    # In the event that flashes on this sweep, trigger flashes on next sweep
    if not done do
      trigger_flashes(new_grid)
    else
      new_grid
    end
  end

  def count_flashes(grid) do
    count =
      Enum.reduce(grid, 0, fn {_, v}, acc ->
        if v == 0, do: acc + 1, else: acc
      end)

    {grid, count}
  end

  def all_flashes(grid) do
    Enum.all?(grid, fn {_, v} -> v == 0 end)
  end
end
