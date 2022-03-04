defmodule AdventOfCode.Day02 do
  defmodule Command do
    @enforce_keys [:direction, :units]
    defstruct [:direction, :units]
  end

  defmodule Position do
    defstruct horizontal: 0, depth: 0, aim: 0
  end

  def part1(args) do
    args
    |> parse_input()
    |> run_program(&exec_command/2)
  end

  def part2(args) do
    args
    |> parse_input()
    |> run_program(&exec_command_2/2)
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_command/1)
  end

  def parse_command(c) do
    [direction, units] = String.split(c, " ")
    %Command{direction: direction, units: String.to_integer(units)}
  end

  def run_program(commands, executor) do
    commands
    |> List.foldl(%Position{}, executor)
    |> calculate_result()
  end

  def exec_command(c, pos) do
    case c do
      %{direction: "forward"} -> %{pos | horizontal: pos.horizontal + c.units}
      %{direction: "down"} -> %{pos | depth: pos.depth + c.units}
      %{direction: "up"} -> %{pos | depth: pos.depth - c.units}
    end
  end

  def exec_command_2(c, pos) do
    case c do
      %{direction: "forward"} ->
        %{pos | horizontal: pos.horizontal + c.units, depth: pos.depth + pos.aim * c.units}

      %{direction: "down"} ->
        %{pos | aim: pos.aim + c.units}

      %{direction: "up"} ->
        %{pos | aim: pos.aim - c.units}
    end
  end

  def calculate_result(%Position{horizontal: h, depth: d}), do: h * d
end
