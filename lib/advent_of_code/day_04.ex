defmodule AdventOfCode.Day04 do

  defmodule Bingo do
    @enforce_keys [:calls, :boards]
    defstruct [:calls, :boards]
  end

  defmodule Board do
    defstruct board: %{}, has_won: false
  end

  defmodule Cell do
    defstruct number: 0, marked: false 
  end

  def part1(args) do
    args
    |> parse_input()
    |> run_bingo()
    |> score_board()
  end

  def part2(args) do
    args
    |> parse_input()
    |> run_bingo_last()
    |> score_board()
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> parse_bingo()
  end

  def parse_bingo([bingo_calls | tail]) do
    calls = bingo_calls
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)

    boards = tail
    |> Enum.chunk_every(5)
    |> Enum.map(&parse_bingo_board/1)

    %Bingo{calls: calls, boards: boards}
  end

  def parse_bingo_board(lines) do
    board_numbers = lines
    |> Enum.map(&String.split/1)
    |> Enum.flat_map(fn l -> l end)
    |> Enum.map(&String.to_integer/1)

    {board, _} = Enum.reduce(board_numbers, {%Board{}, 0}, fn val, {board, current} ->
      new_board = Map.put(board.board, {div(current, 5), rem(current, 5)}, %Cell{number: val})
      {%{board | board: new_board}, current + 1}
    end)
    board
  end

  def run_bingo(%Bingo{calls: calls, boards: boards}) do
    {finished_boards, call} = Enum.reduce_while(calls, boards, fn call, boards ->
      new_boards = Enum.map(boards, &run_bingo_call(&1, call))
      if Enum.any?(new_boards, fn x -> x.has_won end), do: {:halt, {new_boards, call}}, else: {:cont, new_boards}
    end)
    winning_board = finished_boards
    |> Enum.find(fn x -> x.has_won end)
    {winning_board, call}
  end

  def run_bingo_last(%Bingo{calls: calls, boards: boards}) do
    Enum.reduce_while(calls, boards, fn call, boards ->
      new_boards = Enum.map(boards, &run_bingo_call(&1, call))
      case new_boards do
        [%{has_won: true} = board] -> {:halt, {board, call}}
        [board] -> {:cont, [board]}
        boards -> {:cont, Enum.filter(boards, fn x -> not x.has_won end)}
      end
    end)
  end

  def run_bingo_call(%Board{board: board} = bingo_board, number) do
    case Enum.find(board, fn {_, cell} -> cell.number == number end) do
      {coord, cell} ->
        new_board = Map.put(board, coord, %{cell | marked: true})
        %{bingo_board | board: new_board, has_won: check_board(new_board, coord)}
      nil -> bingo_board
    end
  end

  def check_board(board, {row, col}) do
    Enum.all?(get_row(board, row), fn {_, cell} -> cell.marked end) ||
    Enum.all?(get_column(board, col), fn {_, cell} -> cell.marked end)
  end

  def get_row(board, index) do
    Enum.filter(board, fn {{row, _col}, _cell} -> row == index end)
  end
  def get_column(board, index) do
    Enum.filter(board, fn {{_row, col}, _cell} -> col == index end)
  end

  def score_board({board, number}) do
    board.board
    |> Enum.filter(fn {{_, _}, %{marked: marked}} -> not marked end)
    |> Enum.map(fn {_, cell} -> cell.number end)
    |> Enum.sum()
    |> (fn x -> x * number end).()
  end

end
