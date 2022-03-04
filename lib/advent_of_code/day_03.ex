defmodule AdventOfCode.Day03 do
  def part1(args) do
    args
    |> parse_input()
    |> transpose()
    |> Enum.map(&decode_gamma_epsilon_val/1)
    |> transpose()
    |> Enum.map(&Enum.join/1)
    |> Enum.map(fn x -> elem(Integer.parse(x, 2), 0) end)
    |> Enum.product()
  end

  def part2(args) do
    args
    |> parse_input()
    |> then(fn x -> [decode_oxygen_val(x, 0), decode_c02_val(x, 0)] end)
    |> Enum.product()
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  def transpose(rows) do
    rows
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  def decode_gamma_epsilon_val(row) do
    row
    |> Enum.frequencies()
    |> get_gamma_epison_val()
  end

  def get_gamma_epison_val(freq) do
    [elem(Enum.max_by(freq, &elem(&1, 1)), 0), elem(Enum.min_by(freq, &elem(&1, 1)), 0)]
  end

  def decode_oxygen_val([one], _), do: elem(Integer.parse(Enum.join(one), 2), 0)

  def decode_oxygen_val(rows, idx) do
    freqs = Enum.frequencies_by(rows, fn x -> Enum.at(x, idx) end)
    zero_count = Map.get(freqs, "0")
    one_count = Map.get(freqs, "1")

    max_elem =
      if zero_count > one_count do
        "0"
      else
        "1"
      end

    filtered_rows = Enum.filter(rows, fn x -> Enum.at(x, idx) == max_elem end)
    decode_oxygen_val(filtered_rows, idx + 1)
  end

  def decode_c02_val([one], _), do: elem(Integer.parse(Enum.join(one), 2), 0)

  def decode_c02_val(rows, idx) do
    freqs = Enum.frequencies_by(rows, fn x -> Enum.at(x, idx) end)
    zero_count = Map.get(freqs, "0")
    one_count = Map.get(freqs, "1")

    min_elem =
      if one_count < zero_count do
        "1"
      else
        "0"
      end

    filtered_rows = Enum.filter(rows, fn x -> Enum.at(x, idx) == min_elem end)
    decode_c02_val(filtered_rows, idx + 1)
  end
end
