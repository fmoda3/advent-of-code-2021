defmodule AdventOfCode.Day14 do
  def part1(args) do
    {template, pair_counts, rules} = parse_input(args)
    final_pair_counts = run_steps(pair_counts, rules, 10)
    max_minus_min(final_pair_counts, template)
  end

  def part2(args) do
    {template, pair_counts, rules} = parse_input(args)
    final_pair_counts = run_steps(pair_counts, rules, 40)
    max_minus_min(final_pair_counts, template)
  end

  def parse_input(input) do
    [template, rules] = String.split(input, "\n\n", trim: true)
    {template, to_pair_counts(template), to_rules(rules)}
  end

  def to_pair_counts(template) do
    template
    |> String.graphemes()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(&Enum.join/1)
    |> Enum.reduce(%{}, fn x, pair_counts -> Map.update(pair_counts, x, 1, &(&1 + 1)) end)
  end

  def to_rules(rules) do
    rules
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " -> "))
  end

  def run_steps(pair_counts, _, 0), do: pair_counts
  def run_steps(pair_counts, rules, n) do
    # What we want to do here, is to iterate through all the pairs, and find the associated rule.
    # With the rule, we take the original pair, form two new pairs, and add the count to those
    # new pairs in the map
    # I.e., if Rule is NB -> C, then the NB pair becomes NC and CB pairs, NB's count gets added to
    # NC and CB's counts
    Enum.reduce(pair_counts, %{}, fn {pair, count}, new_pair_counts ->
      case find_rule(pair, rules) do
        [_, insertion] ->
          [first, second] = String.graphemes(pair)
          new_pair_counts
          |> Map.update(first <> insertion, count, &(&1 + count))
          |> Map.update(insertion <> second, count, &(&1 + count))
        nil -> new_pair_counts
      end
    end)
    |> run_steps(rules, n - 1)
  end

  def find_rule(chunk, rules) do
    Enum.find(rules, fn [pair, _] -> pair == chunk end)
  end

  def max_minus_min(pair_counts, original_template) do
    # So, we can find the number of letters by adding up the counts of the first letter in each pair
    # plus adding 1 for the last letter in the string (since we are not touching the 2nd letter in the pairs)
    last_letter = original_template
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.at(0)

    pair_counts
    |> Enum.reduce(%{}, fn {pair, count}, counts ->
      # Only sum the first letter of each pair (otherwise we will double count)
      [first, _] = String.graphemes(pair)
      Map.update(counts, first, count, &(&1 + count))
    end)
    |> Map.update(last_letter, 1, &(&1 + 1)) # Add 1 for the last letter
    # Alright, time to calculate max - min
    |> Enum.map(fn {_, count} -> count end)
    |> Enum.min_max()
    |> (fn {min, max} -> max - min end).()
  end
end
