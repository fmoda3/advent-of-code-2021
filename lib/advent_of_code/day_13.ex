defmodule AdventOfCode.Day13 do

  def part1(args) do
    {grid, [first_ins | _]} = args
    |> parse_input()
    fold_page(first_ins, grid)
    |> Enum.count()
  end

  def part2(args) do
    {grid, instructions} = args
    |> parse_input()
    code = instructions
    |> Enum.reduce(grid, &fold_page(&1, &2))
    |> page_to_string()
    # Uncomment to show code, don't want it printing during "mix test"
    # IO.puts(code)
    code
    # My result
    # ###..####.####.#..#.###...##..####.###.
    # #..#....#.#....#..#.#..#.#..#.#....#..#
    # #..#...#..###..####.#..#.#..#.###..#..#
    # ###...#...#....#..#.###..####.#....###.
    # #....#....#....#..#.#.#..#..#.#....#.#.
    # #....####.####.#..#.#..#.#..#.####.#..#
  end

  def parse_input(input) do
    [coords, folds] = String.split(input, "\n\n", trim: true)
    {to_grid(coords), to_instructions(folds)}
  end

  def to_grid(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ","))
    |> Enum.reduce(MapSet.new(), fn [col, row], grid ->
      MapSet.put(grid, {String.to_integer(col), String.to_integer(row)})
    end)
  end

  def to_instructions(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn x ->
      case x do
        "fold along y=" <> y -> {:row, String.to_integer(y)}
        "fold along x=" <> x -> {:col, String.to_integer(x)}
      end
    end)
  end

  def fold_page({:row, y}, grid) do
    Enum.reduce(grid, MapSet.new(), fn {col, row}, new_grid ->
      cond do
        row < y -> MapSet.put(new_grid, {col, row})
        row > y -> MapSet.put(new_grid, {col, y-(row-y)})
        true -> new_grid
      end
    end)
  end

  def fold_page({:col, x}, grid) do
    Enum.reduce(grid, MapSet.new(), fn {col, row}, new_grid ->
      cond do
        col < x -> MapSet.put(new_grid, {col, row})
        col > x -> MapSet.put(new_grid, {x-(col-x), row})
        true -> new_grid
      end
    end)
  end

  def page_to_string(grid) do
    max_x = Enum.reduce(grid, 0, fn {col, _}, x -> if col > x, do: col, else: x end)
    max_y = Enum.reduce(grid, 0, fn {_, row}, y -> if row > y, do: row, else: y end)
    for row <- 0..max_y do
      for col <- 0..max_x do
        if MapSet.member?(grid, {col, row}), do: "#", else: "."
      end
      |> Enum.join()
    end
    |> Enum.join("\n")
    |> Kernel.<>("\n")
  end

end
