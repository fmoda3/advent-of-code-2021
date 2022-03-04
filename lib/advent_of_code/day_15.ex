defmodule AdventOfCode.Day15 do
  def part1(args) do
    args
    |> parse_input(1)
    |> run_dijkstra()
  end

  def part2(args) do
    args
    |> parse_input(5)
    |> run_dijkstra()
  end

  def parse_input(input, multiple) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
    |> to_grid(multiple)
  end

  def to_grid(input, multiple) do
    width = Enum.count(Enum.at(input, 0))
    height = Enum.count(input)

    grid =
      for col <- 0..(width * multiple - 1), row <- 0..(height * multiple - 1), into: %{} do
        val =
          input
          |> Enum.at(rem(row, height))
          |> Enum.at(rem(col, width))
          |> String.to_integer()
          |> (fn x -> x + div(col, width) + div(row, height) end).()
          |> (fn x -> rem(x, 10) + div(x, 10) end).()

        {{col, row}, val}
      end

    {grid, width * multiple, height * multiple}
  end

  def run_dijkstra({grid, width, height}) do
    # Prep the risk grid with int max for all values, except the starting node, which is 0
    risk_grid =
      grid
      |> Enum.reduce(%{}, fn {coord, _}, acc -> Map.put(acc, coord, 536_870_911) end)
      |> Map.put({0, 0}, 0)

    # We want to use a priority queue, to always be processing the node with the shortest distance first
    queue =
      PriorityQueue.new()
      |> PriorityQueue.put(0, {0, 0})

    run_dijkstra(grid, width, height, risk_grid, queue)
  end

  def run_dijkstra(grid, width, height, risk_grid, queue) do
    {{risk, coord}, queue} = PriorityQueue.pop(queue)

    case risk do
      # Reached the end of the queue
      nil ->
        Map.get(risk_grid, {height - 1, width - 1})

      # Keep going
      _ ->
        {col, row} = coord
        # Check all the neighbors
        {risk_grid, queue} =
          [{col + 1, row}, {col - 1, row}, {col, row - 1}, {col, row + 1}]
          |> Enum.reduce({risk_grid, queue}, fn new_coord, {risk_grid, queue} ->
            add_node(new_coord, grid, risk, risk_grid, height, width, queue)
          end)

        run_dijkstra(grid, width, height, risk_grid, queue)
    end
  end

  def add_node({col, row}, grid, risk, risk_grid, height, width, queue) do
    # If a neighbor needs to be updated, update it, and add it to the queue for further processing
    if row >= 0 and row < height and col >= 0 and col < width and
         Map.get(risk_grid, {col, row}) > risk + Map.get(grid, {col, row}) do
      new_risk = risk + Map.get(grid, {col, row})
      {Map.put(risk_grid, {col, row}, new_risk), PriorityQueue.put(queue, new_risk, {col, row})}
    else
      {risk_grid, queue}
    end
  end
end
