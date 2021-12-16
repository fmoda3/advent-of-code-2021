defmodule AdventOfCode.Day16 do

  def part1(args) do
    args
    |> parse_input()
    |> count_versions()
  end

  def part2(args) do
    args
    |> parse_input()
    |> calc_value()
  end

  def parse_input(input) do
    input
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&char_to_binary/1)
    |> Enum.join()
    |> String.graphemes()
    |> parse_packet()
    |> (fn {packet, _} -> packet end).()
  end

  # Parse the headers off the current packet
  def parse_packet([v1, v2, v3, t1, t2, t3 | rest]) do
    version = binary_to_integer([v1, v2, v3])
    type = binary_to_integer([t1, t2, t3])
    parse_packet(version, type, rest)
  end
  # Handle extra 0s
  def parse_packet(_), do: {nil, nil}

  # Parse literal packet
  def parse_packet(version, 4, body) do
    {literal_binary, rest} = parse_literal_body(body)
    case literal_binary do
      nil -> {nil, nil}
      _ -> {{:literal, version, binary_to_integer(literal_binary)}, rest}
    end
  end
  # Parse operator with length type 0
  def parse_packet(version, type, ["0" | body]) do
    {packets, rest} = parse_total_length_operator(body)
    case packets do
      nil -> {nil, nil}
      _ -> {{:operator, version, type, packets}, rest}
    end
  end
  # Parse operator with length type 1
  def parse_packet(version, type, ["1" | body]) do
    {packets, rest} = parse_num_subpackets_operator(body)
    case packets do
      nil -> {nil, nil}
      _ -> {{:operator, version, type, packets}, rest}
    end
  end
  # Handle extra 0s
  def parse_packet(_, _, []), do: {nil, nil}

  def parse_literal_body(["0", b1, b2, b3, b4]), do: {[b1, b2, b3, b4], []}
  def parse_literal_body(["0", b1, b2, b3, b4 | rest]), do: {[b1, b2, b3, b4], rest}
  def parse_literal_body(["1", b1, b2, b3, b4 | rest]) do
    {next, rest} = parse_literal_body(rest)
    {[b1, b2, b3, b4] ++ next, rest}
  end
  def parse_literal_body(_), do: {nil, nil}

  def parse_total_length_operator([l1, l2, l3, l4, l5, l6, l7, l8, l9, l10, l11, l12, l13, l14, l15 | rest]) do
    length = binary_to_integer([l1, l2, l3, l4, l5, l6, l7, l8, l9, l10, l11, l12, l13, l14, l15])
    body = Enum.take(rest, length)
    rest = Enum.drop(rest, length)
    {parse_packets(body), rest}
  end
  # Handle extra 0s
  def parse_total_length_operator(_), do: {nil, nil}

  # Helper to parse unknown number of packets for the total length operator
  def parse_packets(input) do
    {packet, rest} = parse_packet(input)
    case packet do
      nil -> []
      _ -> [packet] ++ parse_packets(rest)
    end
  end

  def parse_num_subpackets_operator([n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11 | rest]) do
    number = binary_to_integer([n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11])
    Enum.reduce(1..number, {[], rest}, fn _, {packets, rest} ->
      {packet, rest} = parse_packet(rest)
      {packets ++ [packet], rest}
    end)
  end
  # Handle extra 0s
  def parse_num_subpackets_operator(_), do: {nil, nil}

  def count_versions([packet]), do: count_versions(packet)
  def count_versions([packet | rest]), do: count_versions(packet) + count_versions(rest)
  def count_versions({:literal, version, _}), do: version
  def count_versions({:operator, version, _, children}), do: version + count_versions(children)

  def calc_value({:literal, _, val}), do: val
  def calc_value({:operator, _, 0, children}), do: calc_children(children, &Enum.sum/1)
  def calc_value({:operator, _, 1, children}), do: calc_children(children, &Enum.product/1)
  def calc_value({:operator, _, 2, children}), do: calc_children(children, &Enum.min/1)
  def calc_value({:operator, _, 3, children}), do: calc_children(children, &Enum.max/1)
  def calc_value({:operator, _, 5, children}), do: compare_children(children, &Kernel.>/2)
  def calc_value({:operator, _, 6, children}), do: compare_children(children, &Kernel.</2)
  def calc_value({:operator, _, 7, children}), do: compare_children(children, &Kernel.==/2)

  def calc_children(children, op) do
    children
    |> Enum.map(&calc_value/1)
    |> op.()
  end
  def compare_children([first, second], op) do
    first_value = calc_value(first)
    second_value = calc_value(second)
    if op.(first_value, second_value), do: 1, else: 0
  end

  def binary_to_integer(array) do
    array
    |> Enum.join()
    |> String.to_integer(2)
  end

  def char_to_binary(char) do
    case char do
      "0" -> "0000"
      "1" -> "0001"
      "2" -> "0010"
      "3" -> "0011"
      "4" -> "0100"
      "5" -> "0101"
      "6" -> "0110"
      "7" -> "0111"
      "8" -> "1000"
      "9" -> "1001"
      "A" -> "1010"
      "B" -> "1011"
      "C" -> "1100"
      "D" -> "1101"
      "E" -> "1110"
      "F" -> "1111"
    end
  end

end
