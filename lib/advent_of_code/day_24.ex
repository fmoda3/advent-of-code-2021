defmodule AdventOfCode.Day24 do

  def part1(args) do
    {register, instructions} = args
    |> parse_input()          # a b c d e f g h i j k l m n
    run_instructions(register, [9,2,9,2,8,9,1,4,9,9,9,9,9,1], instructions)
    |> (fn {register, _} ->
      Map.get(register, "z") == 0
    end).()
  end

  # a -> z*26+4
  # b -> z*26+11
  # c -> z*26+7
  # d -> z%26-14
  # e -> z*26+11
  # f -> z%26-10
  # g -> z*26+9
  # h -> z*26+12
  # i -> z%26-7
  # j -> z*26+2
  # k -> z%26-2
  # l -> z%26-1
  # m -> z%26-4
  # n -> z%26-12
  # looks like some steps go up (* steps) and some go down (% steps)
  # pair up down steps with the closest up step, and subtract the constants
  # pairs -> [cd, ef, hi, jk, gl, bm, an]
  # pairs -> [-7, +1, +5, +0, +8, +7, -8]
  # pairs -> [92, 89, 49, 99, 19, 29, 91] <- maximum possible values
  # [92928914999991]

  def part2(args) do
    {register, instructions} = args
    |> parse_input()          # a b c d e f g h i j k l m n
    run_instructions(register, [9,1,8,1,1,2,1,1,6,1,1,9,8,1], instructions)
    |> (fn {register, _} ->
      Map.get(register, "z") == 0
    end).()
  end

  # pairs -> [cd, ef, hi, jk, gl, bm, an]
  # pairs -> [-7, +1, +5, +0, +8, +7, -8]
  # pairs -> [81, 12, 16, 11, 19, 18, 91] <- minimum possible values
  # [91811211611981]

  def parse_input(input) do
    instructions = input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(&parse_instruction/1)
    register = %{"w" => 0, "x" => 0, "y" => 0, "z" => 0}
    {register, instructions}
  end

  def parse_instruction([inst, a]), do: {String.to_atom(inst), a}
  def parse_instruction([inst, a, b]) do
    case Integer.parse(b) do
      :error -> {String.to_atom(inst), a, b}
      {i, _} -> {String.to_atom(inst), a, i}
    end
  end

  def run_instructions(register, input, instructions) do
    Enum.reduce(instructions, {register, input}, fn inst, {register, input} ->
      run_instruction(register, input, inst)
    end)
  end

  def run_instruction(register, [head | tail], {:inp, a}) do
    register = Map.put(register, a, head)
    {register, tail}
  end
  def run_instruction(register, input, {inst, a, b}) do
    a_val = Map.get(register, a)
    b_val = if is_integer(b), do: b, else: Map.get(register, b)
    new_val = case inst do
      :add -> a_val + b_val
      :mul -> a_val * b_val
      :div -> div(a_val, b_val)
      :mod -> rem(a_val, b_val)
      :eql -> if a_val == b_val do 1 else 0 end
    end
    {Map.put(register, a, new_val), input}
  end

end
