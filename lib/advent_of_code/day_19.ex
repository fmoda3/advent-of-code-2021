defmodule AdventOfCode.Day19 do
  def part1(args) do
    args
    |> parse_input()
    |> compare_scanners()
    |> Map.values()
    |> Enum.map(fn {beacons, _} -> beacons end)
    |> Enum.concat()
    |> Enum.uniq()
    |> Enum.count()
  end

  def part2(args) do
    args
    |> parse_input()
    |> compare_scanners()
    |> Map.values()
    |> Enum.map(fn {_, delta} -> delta end)
    |> permute()
    |> Enum.map(&distance/1)
    |> Enum.max()
  end

  def parse_input(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_scanner/1)
  end

  def parse_scanner(input) do
    [scanner | beacons] = String.split(input, "\n", trim: true)
    [_, _, scanner_num, _] = String.split(scanner, " ")

    beacons =
      beacons
      |> Enum.map(&parse_beacon/1)

    {scanner_num, beacons}
  end

  def parse_beacon(line) do
    line
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def permute([]), do: []

  def permute([head | tail]) do
    Enum.map(tail, fn t -> {head, t} end) ++ permute(tail)
  end

  # By the end of compare_scanners, foundmap should contain all the original scanners,
  # but with all their beacons re-oriented to be from scanner 0's perspective
  def compare_scanners(scanners) do
    [{num, beacons} | tail] = scanners
    foundmap = Map.put(%{}, num, {beacons, [0, 0, 0]})
    compare_scanners(foundmap, tail)
  end

  def compare_scanners(foundmap, []), do: foundmap

  def compare_scanners(foundmap, tofind) do
    {matched_num, matched_beacons, delta, scanner} = compare_scanners_helper(foundmap, tofind)
    new_found_map = Map.put(foundmap, matched_num, {matched_beacons, delta})
    compare_scanners(new_found_map, tofind -- [scanner])
  end

  # This searches for the next match, by traversing the unmatched list
  # and comparing it to each beacon that's already been matched and re-oriented
  # to scanner 0
  def compare_scanners_helper(foundmap, [{s2name, s2beacons} | tail]) do
    result =
      Enum.reduce_while(Map.keys(foundmap), nil, fn s1name, acc ->
        {s1beacons, _} = Map.get(foundmap, s1name)

        case compare_beacons(s1beacons, s2beacons) do
          nil -> {:cont, acc}
          {news2beacons, delta} -> {:halt, {news2beacons, delta}}
        end
      end)

    case result do
      nil -> compare_scanners_helper(foundmap, tail)
      {matched_beacons, delta} -> {s2name, matched_beacons, delta, {s2name, s2beacons}}
    end
  end

  def compare_beacons(beacons1, beacons2) do
    # Adding this check provided a 20x speedup (10s -> 0.5s)
    case will_beacons_match(beacons1, beacons2) do
      false ->
        nil

      true ->
        # If beacons1 and beacons2 can match, then we need to actually find the rotation that matches
        # and find the delta
        beacons2
        |> rotate_beacons()
        |> Enum.reduce_while(nil, fn testbeacon2, acc ->
          case do_beacons_match(beacons1, testbeacon2) do
            nil ->
              {:cont, acc}

            # Don't continue processing if we find a match
            delta ->
              [d1, d2, d3] = delta
              # Return a new beacons list that is oriented against the first beacon
              reoriented_s2beacons =
                Enum.map(testbeacon2, fn [x, y, z] -> [x + d1, y + d2, z + d3] end)

              {:halt, {reoriented_s2beacons, delta}}
          end
        end)
    end
  end

  # We can do an optimal check if two beacons can even match, by checking if there
  # are coordinates with the same relative distance
  def will_beacons_match(beacons1, beacons2) do
    b1distances = distances(beacons1)
    b2distances = distances(beacons2)
    remaining = b1distances -- b2distances
    # Since we are doing the crossproduct above, you need to check for 144 matches
    # instead of the 12 asked for by the problem (a guess based on the output I was seeing)
    Enum.count(remaining) + 144 <= Enum.count(b1distances)
  end

  def do_beacons_match(beacons1, beacons2) do
    found =
      find_deltas(beacons1, beacons2)
      |> Enum.frequencies_by(fn {_, _, [d1, dy, dz]} -> [d1, dy, dz] end)
      |> Enum.find(fn {_, v} -> v >= 12 end)

    case found do
      nil -> nil
      {delta, _} -> delta
    end
  end

  def find_deltas(beacons1, beacons2) do
    for b1 <- beacons1, b2 <- beacons2 do
      [b1, b2]
    end
    |> Enum.map(fn [[bx1, by1, bz1], [bx2, by2, bz2]] ->
      {[bx1, by1, bz1], [bx2, by2, bz2], [bx1 - bx2, by1 - by2, bz1 - bz2]}
    end)
  end

  def distance({[x1, y1, z1], [x2, y2, z2]}) do
    abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)
  end

  def distances(beacons) do
    for x <- beacons, y <- beacons, x != y do
      {x, y}
    end
    |> Enum.map(&distance/1)
    |> Enum.sort()
  end

  def rotate_beacons(beacons) do
    beacons
    |> Enum.map(&rotate_orientations/1)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  def rotate_orientations([x, y, z]) do
    [
      [x, y, z],
      [y, z, x],
      [z, x, y],
      [z, y, -x],
      [y, x, -z],
      [x, z, -y],
      [x, -y, -z],
      [y, -z, -x],
      [z, -x, -y],
      [z, -y, x],
      [y, -x, z],
      [x, -z, y],
      [-x, y, -z],
      [-y, z, -x],
      [-z, x, -y],
      [-z, y, x],
      [-y, x, z],
      [-x, z, y],
      [-x, -y, z],
      [-y, -z, x],
      [-z, -x, y],
      [-z, -y, -x],
      [-y, -x, -z],
      [-x, -z, -y]
    ]
  end
end
