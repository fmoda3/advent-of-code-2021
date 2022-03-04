defmodule AdventOfCode.Day20 do
  def part1(args) do
    args
    |> parse_input()
    |> run_steps(2)
    |> count_lit_pixels()
  end

  def part2(args) do
    args
    |> parse_input()
    |> run_steps(50)
    |> count_lit_pixels()
  end

  def parse_input(input) do
    [key_string, image_string] = String.split(input, "\n\n", trim: true)
    key = parse_key(key_string)
    {image, min_col, max_col, min_row, max_row} = parse_grid(image_string)
    all_empty_val = Map.get(key, 0)
    all_filled_val = Map.get(key, 511)
    {key, image, min_col, max_col, min_row, max_row, all_empty_val, all_filled_val}
  end

  def parse_key(key_string) do
    key_string
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(fn {k, v} -> {v, k} end)
    |> Map.new()
  end

  def parse_grid(image_string) do
    image_string
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
    |> to_grid()
  end

  def to_grid(input) do
    width = Enum.count(Enum.at(input, 0))
    height = Enum.count(input)

    grid =
      for col <- 0..(width - 1),
          row <- 0..(height - 1),
          into: %{},
          do: {{col, row}, Enum.at(Enum.at(input, row), col)}

    {grid, 0, width, 0, height}
  end

  def run_steps(
        {key, image, min_col, max_col, min_row, max_row, all_empty_val, all_filled_val},
        n
      ) do
    run_steps(
      {key, image, min_col - 1, max_col + 1, min_row - 1, max_row + 1, all_empty_val,
       all_filled_val},
      n,
      n
    )
  end

  def run_steps({_, image, _, _, _, _, _, _}, 0, _), do: image

  def run_steps(
        {key, image, min_col, max_col, min_row, max_row, all_empty_val, all_filled_val},
        n,
        first_step
      ) do
    coords_to_check =
      for col <- (min_col - 1)..(max_col + 1), row <- (min_row - 1)..(max_row + 1), do: {col, row}

    current_void_val = get_current_void_val(first_step, n, all_empty_val, all_filled_val)

    output_image =
      Enum.reduce(coords_to_check, %{}, fn coord, output ->
        Map.put(output, coord, get_square_val(key, image, coord, current_void_val))
      end)

    run_steps(
      {key, output_image, min_col - 1, max_col + 1, min_row - 1, max_row + 1, all_empty_val,
       all_filled_val},
      n - 1,
      first_step
    )
  end

  def get_current_void_val(first_step, curr_step, all_empty_val, all_filled_val) do
    case {all_empty_val, all_filled_val} do
      # Void doesn't flash at all
      {".", _} -> "."
      # Void is initially off, but lights and stays lit indefinitely
      # Probably never used in the key, as it would make the "lit" count infinite at the end.
      {"#", "#"} -> if first_step == curr_step, do: ".", else: "#"
      # Void flashes on and off
      {"#", "."} -> if rem(curr_step, 2) == 0, do: ".", else: "#"
    end
  end

  def get_square_val(key, image, {col, row}, current_void_val) do
    {prev_col, next_col, prev_row, next_row} = {col - 1, col + 1, row - 1, row + 1}

    (get_pixel(image, {prev_col, prev_row}, current_void_val) <>
       get_pixel(image, {col, prev_row}, current_void_val) <>
       get_pixel(image, {next_col, prev_row}, current_void_val) <>
       get_pixel(image, {prev_col, row}, current_void_val) <>
       get_pixel(image, {col, row}, current_void_val) <>
       get_pixel(image, {next_col, row}, current_void_val) <>
       get_pixel(image, {prev_col, next_row}, current_void_val) <>
       get_pixel(image, {col, next_row}, current_void_val) <>
       get_pixel(image, {next_col, next_row}, current_void_val))
    |> String.to_integer(2)
    |> (&Map.get(key, &1)).()
  end

  def get_pixel(image, coord, current_void_val) do
    case Map.get(image, coord) do
      nil -> pixel_to_binary(current_void_val)
      x -> pixel_to_binary(x)
    end
  end

  def pixel_to_binary(pixel) do
    case pixel do
      "#" -> "1"
      "." -> "0"
    end
  end

  def count_lit_pixels(image) do
    Enum.count(image, fn {_, val} -> val == "#" end)
  end
end
