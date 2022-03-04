defmodule AdventOfCode.Day22 do
  def part1(args) do
    args
    |> parse_input()
    |> Enum.filter(fn {x1, x2, y1, y2, z1, z2, _} ->
      x1 in -51..51 and x2 in -51..51 and
        y1 in -51..51 and y2 in -51..51 and
        z1 in -51..51 and z2 in -51..51
    end)
    |> process_cubes()
    |> count_on()
  end

  def part2(args) do
    args
    |> parse_input()
    |> process_cubes()
    |> count_on()
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_cube/1)
  end

  def parse_cube(line) do
    [inst, coords] = String.split(line, " ")
    [xstring, ystring, zstring] = String.split(coords, ",")
    [x1, x2] = parse_coord(xstring)
    [y1, y2] = parse_coord(ystring)
    [z1, z2] = parse_coord(zstring)
    # Range needs to be end inclusive
    {x1, x2 + 1, y1, y2 + 1, z1, z2 + 1, String.to_atom(inst)}
  end

  def parse_coord(coord) do
    coord
    |> String.split("=")
    |> Enum.at(1)
    |> String.split("..")
    |> Enum.map(&String.to_integer/1)
  end

  def process_cubes(cubes), do: Enum.reduce(cubes, [], &process_cube/2)

  def process_cube(next_cube, prev_cubes) do
    Enum.reduce(prev_cubes, [next_cube], fn prev_cube, new_cubes ->
      new_cubes ++ split_cube(next_cube, prev_cube)
    end)
  end

  # Finds the intersection of two cubes, and turns the latter cube into 0-6 cubes in order to remove
  # the intersecting volume from it
  # Ex. split_cube({1,5,1,5,1,5,:on},{0,6,0,6,0,6,:on}) should return
  # [
  #  {0, 1, 0, 6, 0, 6, :on},
  #  {5, 6, 0, 6, 0, 6, :on},
  #  {1, 5, 0, 1, 0, 6, :on},
  #  {1, 5, 5, 6, 0, 6, :on},
  #  {1, 5, 1, 5, 0, 1, :on},
  #  {1, 5, 1, 5, 5, 6, :on}
  # ]
  # since cube_a is entirely inside cube_b
  def split_cube(cube_a, cube_b) do
    {bx1, bx2, by1, by2, bz1, bz2, binst} = cube_b

    case does_intersect(cube_a, cube_b) do
      true ->
        # Slice left side (-x)
        {left_cube, bx1} = slice_left(cube_a, {bx1, bx2, by1, by2, bz1, bz2, binst})
        # Slice right side (+x)
        {right_cube, bx2} = slice_right(cube_a, {bx1, bx2, by1, by2, bz1, bz2, binst})
        # Slice bottom side (-y)
        {bottom_cube, by1} = slice_bottom(cube_a, {bx1, bx2, by1, by2, bz1, bz2, binst})
        # Slice top side (+y)
        {top_cube, by2} = slice_top(cube_a, {bx1, bx2, by1, by2, bz1, bz2, binst})
        # Slice back side (-z)
        {back_cube, bz1} = slice_back(cube_a, {bx1, bx2, by1, by2, bz1, bz2, binst})
        # Slice front side (+z)
        {front_cube, _} = slice_front(cube_a, {bx1, bx2, by1, by2, bz1, bz2, binst})
        # Return all cubes (anywhere from 0 to 6 new cubes)
        left_cube ++ right_cube ++ bottom_cube ++ top_cube ++ back_cube ++ front_cube

      # If they don't intersect, original cube is unmodified
      _ ->
        [cube_b]
    end
  end

  def does_intersect({ax1, ax2, ay1, ay2, az1, az2, _}, {bx1, bx2, by1, by2, bz1, bz2, _}) do
    x_overlaps = ax1 < bx2 and bx1 < ax2
    y_overlaps = ay1 < by2 and by1 < ay2
    z_overlaps = az1 < bz2 and bz1 < az2
    x_overlaps and y_overlaps and z_overlaps
  end

  def slice_left(cube_a, cube_b), do: slice(cube_a, cube_b, 0, 1, &Kernel.</2)
  def slice_right(cube_a, cube_b), do: slice(cube_a, cube_b, 1, 0, &Kernel.>/2)
  def slice_bottom(cube_a, cube_b), do: slice(cube_a, cube_b, 2, 3, &Kernel.</2)
  def slice_top(cube_a, cube_b), do: slice(cube_a, cube_b, 3, 2, &Kernel.>/2)
  def slice_back(cube_a, cube_b), do: slice(cube_a, cube_b, 4, 5, &Kernel.</2)
  def slice_front(cube_a, cube_b), do: slice(cube_a, cube_b, 5, 4, &Kernel.>/2)
  # Takes two cubes, checks for the intersecting plane given by "op" and "check_index"
  # and returns a new cube that is outside the interesection.  Also returns a new val
  # for one dimension of the original cube (to shrink it)
  # Ex. slice({1,5,1,5,1,5,:on},{0,6,0,6,0,6,:on}, 0, 1, &Kernel.</2) should return
  # {[{0, 1, 0, 6, 0, 6, :on}], 1} which is the left remaining slice, after removing
  # cube_a from cube_b, with the new val for what x1 should be on cube_b for future slicing
  def slice(cube_a, cube_b, check_index, insert_index, op) do
    cube_a_val = elem(cube_a, check_index)
    cube_b_val = elem(cube_b, check_index)

    cond do
      op.(cube_b_val, cube_a_val) -> {[put_elem(cube_b, insert_index, cube_a_val)], cube_a_val}
      true -> {[], cube_b_val}
    end
  end

  def count_on(cubes) do
    cubes
    |> Enum.map(fn {x1, x2, y1, y2, z1, z2, inst} ->
      case inst do
        :on -> (x2 - x1) * (y2 - y1) * (z2 - z1)
        :off -> 0
      end
    end)
    |> Enum.sum()
  end
end
