defmodule AdventOfCode.Day18 do

  def part1(args) do
    args
    |> parse_input()
    |> Enum.reduce(fn x, acc -> add(acc, x) end)
    |> magnitude()
  end

  def part2(args) do
    args
    |> parse_input()
    |> permute()
    |> Enum.map(fn {a, b} -> add(a, b) end)
    |> Enum.map(&magnitude/1)
    |> Enum.max()
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    # Interestingly, the input is valid Elixir array syntax
    |> Enum.map(&Code.eval_string/1)
    |> Enum.map(fn {val, _} -> val end)
  end

  def add(a, b), do: reduce([a, b])

  # Reduces expressions until no reductions can be made
  # Checks explosions first, splits 2nd
  def reduce(x) do
    case explode(x) do
      {true, _, x, _} -> reduce(x)
      {false, _, x, _} ->
        case split(x) do
          {true, x} -> reduce(x)
          {false, x} -> x
        end
    end
  end

  # So, explode basically treats the input like a binary tree
  # It does DFS from left to right, looking for an explosion
  def explode(x), do: explode(x, 4)
  # If we are at a pair at explosion depth, change node to 0, return left and right values
  def explode([a, b], 0), do: {true, a, 0, b}
  # For when we are at a pair at any other depth
  def explode([a, b], n) do
    # Check for explosion on left side
    case explode(a, n-1) do
      # If we exploded on the left, we need to add the right value to the
      # leftmost value in the right subtree
      {true, left, a, right} -> {true, left, [a, add_left(b, right)], nil}
      {false, _, a, _} ->
        # Check for explosion on right side
        case explode(b, n-1) do
          # If we exploded on the right, we need to add the left value to the
          # rightmost value in the left subtree
          {true, left, b, right} -> {true, nil, [add_right(a, left), b], right}
          # If nothing exploded, retain [a, b] as is
          {false, _, _, _} -> {false, nil, [a, b], nil}
        end
    end
  end
  # Must be at a number node
  def explode(x, _), do: {false, nil, x, nil}

  # This traverses a tree down its left side, adding n to the leftmost number value
  def add_left(x, nil), do: x
  def add_left([a, b], n), do: [add_left(a, n), b]
  def add_left(x, n), do: x + n

  # This traverses a tree down its right side, adding n to the rightmost number value
  def add_right(x, nil), do: x
  def add_right([a, b], n), do: [a, add_right(b, n)]
  def add_right(x, n), do: x + n

  # Split also traverses like a binary tree, but it looks for the
  # leftmost node thats >= 10, and splits it
  def split([a, b]) do
    # Try to split left
    case split(a) do
      # Return new node (a is now a pair)
      {true, a} -> {true, [a, b]}
      {false, a} ->
        # Try to split right
        case split(b) do
          # Return new node (b is now a pair)
          {true, b} -> {true, [a, b]}
          # Otherwise, return pair as is
          {false, b} -> {false, [a, b]}
        end
    end
  end
  # Must be an integer, if >= 10, split it, otherwise, return it
  def split(x) when x >= 10, do: {true, [floor(x/2), ceil(x/2)]}
  def split(x), do: {false, x}

  def magnitude([a, b]), do: 3 * magnitude(a) + 2 * magnitude(b)
  def magnitude(x), do: x

  def permute(list), do: for a <- list, b <- list, a != b, do: {a, b}

end
