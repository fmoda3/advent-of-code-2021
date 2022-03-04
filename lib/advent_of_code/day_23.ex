defmodule AdventOfCode.Day23 do
  def part1(args) do
    IO.puts("Warning: Day 23 part 1 takes 15 seconds")

    args
    |> parse_input()
    |> part1_graph()
    |> find_solution()
  end

  def part2(args) do
    IO.puts("Warning: Day 23 part 2 takes 2 minutes")

    args
    |> parse_input()
    |> part2_graph()
    |> find_solution()
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.drop(2)
    |> Enum.take(2)
    |> Enum.map(&String.replace(&1, ~r/\s/, ""))
    |> Enum.map(&String.split(&1, "#", trim: true))
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  def part1_graph([[a1, a2], [b1, b2], [c1, c2], [d1, d2]]) do
    Map.put(%{}, "L2", {"", [{"L1", 1}]})
    |> Map.put("L1", {"", [{"L2", 1}, {"AB", 2}, {"A1", 2}]})
    |> Map.put("AB", {"", [{"L1", 2}, {"BC", 2}, {"A1", 2}, {"B1", 2}]})
    |> Map.put("BC", {"", [{"AB", 2}, {"CD", 2}, {"B1", 2}, {"C1", 2}]})
    |> Map.put("CD", {"", [{"BC", 2}, {"R1", 2}, {"C1", 2}, {"D1", 2}]})
    |> Map.put("R1", {"", [{"R2", 1}, {"CD", 2}, {"D1", 2}]})
    |> Map.put("R2", {"", [{"R1", 1}]})
    |> Map.put("A1", {a1, [{"A2", 1}, {"L1", 2}, {"AB", 2}]})
    |> Map.put("A2", {a2, [{"A1", 1}]})
    |> Map.put("B1", {b1, [{"B2", 1}, {"AB", 2}, {"BC", 2}]})
    |> Map.put("B2", {b2, [{"B1", 1}]})
    |> Map.put("C1", {c1, [{"C2", 1}, {"BC", 2}, {"CD", 2}]})
    |> Map.put("C2", {c2, [{"C1", 1}]})
    |> Map.put("D1", {d1, [{"D2", 1}, {"CD", 2}, {"R1", 2}]})
    |> Map.put("D2", {d2, [{"D1", 1}]})
  end

  def part2_graph([[a1, a2], [b1, b2], [c1, c2], [d1, d2]]) do
    Map.put(%{}, "L2", {"", [{"L1", 1}]})
    |> Map.put("L1", {"", [{"L2", 1}, {"AB", 2}, {"A1", 2}]})
    |> Map.put("AB", {"", [{"L1", 2}, {"BC", 2}, {"A1", 2}, {"B1", 2}]})
    |> Map.put("BC", {"", [{"AB", 2}, {"CD", 2}, {"B1", 2}, {"C1", 2}]})
    |> Map.put("CD", {"", [{"BC", 2}, {"R1", 2}, {"C1", 2}, {"D1", 2}]})
    |> Map.put("R1", {"", [{"R2", 1}, {"CD", 2}, {"D1", 2}]})
    |> Map.put("R2", {"", [{"R1", 1}]})
    |> Map.put("A1", {a1, [{"A2", 1}, {"L1", 2}, {"AB", 2}]})
    |> Map.put("A2", {"D", [{"A1", 1}, {"A3", 1}]})
    |> Map.put("A3", {"D", [{"A2", 1}, {"A4", 1}]})
    |> Map.put("A4", {a2, [{"A3", 1}]})
    |> Map.put("B1", {b1, [{"B2", 1}, {"AB", 2}, {"BC", 2}]})
    |> Map.put("B2", {"C", [{"B1", 1}, {"B3", 1}]})
    |> Map.put("B3", {"B", [{"B2", 1}, {"B4", 1}]})
    |> Map.put("B4", {b2, [{"B3", 1}]})
    |> Map.put("C1", {c1, [{"C2", 1}, {"BC", 2}, {"CD", 2}]})
    |> Map.put("C2", {"B", [{"C1", 1}, {"C3", 1}]})
    |> Map.put("C3", {"A", [{"C2", 1}, {"C4", 1}]})
    |> Map.put("C4", {c2, [{"C3", 1}]})
    |> Map.put("D1", {d1, [{"D2", 1}, {"CD", 2}, {"R1", 2}]})
    |> Map.put("D2", {"A", [{"D1", 1}, {"D3", 1}]})
    |> Map.put("D3", {"C", [{"D2", 1}, {"D4", 1}]})
    |> Map.put("D4", {d2, [{"D3", 1}]})
  end

  def find_solution(graph) do
    PriorityQueue.new()
    |> PriorityQueue.put(0, {graph, []})
    |> find_solution_search()
  end

  def find_solution_search(queue) do
    {{cost, {graph, prev_moves}}, queue} = PriorityQueue.pop(queue)

    if is_done(graph) do
      cost
    else
      valid_moves(graph)
      |> Enum.reduce(queue, fn {start_room, next_room, count}, queue ->
        {start_pod, _} = Map.get(graph, start_room)
        {pod, rooms} = Map.get(graph, start_room)
        new_graph = Map.put(graph, start_room, {"", rooms})
        {_, rooms} = Map.get(graph, next_room)
        new_graph = Map.put(new_graph, next_room, {pod, rooms})

        PriorityQueue.put(
          queue,
          cost + count * energy(start_pod),
          {new_graph, prev_moves ++ [{start_room, next_room, count}]}
        )
      end)
      |> find_solution_search()
    end
  end

  def is_done(graph) do
    {poda1, _} = Map.get(graph, "A1")
    {poda2, _} = Map.get(graph, "A2")
    {poda3, _} = Map.get(graph, "A3", {nil, nil})
    {poda4, _} = Map.get(graph, "A4", {nil, nil})
    {podb1, _} = Map.get(graph, "B1")
    {podb2, _} = Map.get(graph, "B2")
    {podb3, _} = Map.get(graph, "B3", {nil, nil})
    {podb4, _} = Map.get(graph, "B4", {nil, nil})
    {podc1, _} = Map.get(graph, "C1")
    {podc2, _} = Map.get(graph, "C2")
    {podc3, _} = Map.get(graph, "C3", {nil, nil})
    {podc4, _} = Map.get(graph, "C4", {nil, nil})
    {podd1, _} = Map.get(graph, "D1")
    {podd2, _} = Map.get(graph, "D2")
    {podd3, _} = Map.get(graph, "D3", {nil, nil})
    {podd4, _} = Map.get(graph, "D4", {nil, nil})

    poda1 == "A" and poda2 == "A" and (poda3 == "A" or poda3 == nil) and
      (poda4 == "A" or poda4 == nil) and
      podb1 == "B" and podb2 == "B" and (podb3 == "B" or podb3 == nil) and
      (podb4 == "B" or podb4 == nil) and
      podc1 == "C" and podc2 == "C" and (podc3 == "C" or podc3 == nil) and
      (podc4 == "C" or podc4 == nil) and
      podd1 == "D" and podd2 == "D" and (podd3 == "D" or podd3 == nil) and
      (podd4 == "D" or podd4 == nil)
  end

  def valid_moves(graph) do
    # Find all valid adjacent nodes
    moves =
      Enum.reduce(graph, [], fn {room, {pod, _}}, moves ->
        case pod do
          "" ->
            moves

          _ ->
            {new_moves, _, _} = traverse_empty_rooms(graph, room, pod)
            moves ++ [{room, new_moves}]
        end
      end)
      # Flatten the moves array
      |> Enum.reduce([], fn {start_room, steps}, flattened_moves ->
        flattened_moves ++
          Enum.reduce(steps, [], fn {next_room, count}, flattened_steps ->
            flattened_steps ++ [{start_room, next_room, count}]
          end)
      end)

    # If any of the moves results in moving an amphipod to its home, then only use that move
    best_move =
      Enum.find(moves, fn {_, next_room, _} ->
        next_room == "A1" or next_room == "A2" or next_room == "A3" or next_room == "A4" or
          next_room == "B1" or next_room == "B2" or next_room == "B3" or next_room == "B4" or
          next_room == "C1" or next_room == "C2" or next_room == "C3" or next_room == "C4" or
          next_room == "D1" or next_room == "D2" or next_room == "D3" or next_room == "D4"
      end)

    case best_move do
      nil -> moves
      _ -> [best_move]
    end
  end

  def traverse_empty_rooms(graph, room, pod) do
    # If the current pod is at home, don't move it, unless it has to make way for something behind it
    case pod do
      "A" ->
        {poda2, _} = Map.get(graph, "A2")
        {poda3, _} = Map.get(graph, "A3", {nil, nil})
        {poda4, _} = Map.get(graph, "A4", {nil, nil})

        case room do
          "A4" ->
            {[], [], []}

          "A3" ->
            if poda4 == "A" or poda4 == nil,
              do: {[], [], []},
              else: traverse_empty_rooms(graph, room, pod, room_type(room), [room], 0)

          "A2" ->
            if (poda4 == "A" or poda4 == nil) and (poda3 == "A" or poda3 == nil),
              do: {[], [], []},
              else: traverse_empty_rooms(graph, room, pod, room_type(room), [room], 0)

          "A1" ->
            if (poda4 == "A" or poda4 == nil) and (poda3 == "A" or poda3 == nil) and poda2 == "A",
              do: {[], [], []},
              else: traverse_empty_rooms(graph, room, pod, room_type(room), [room], 0)

          _ ->
            traverse_empty_rooms(graph, room, pod, room_type(room), [room], 0)
        end

      "B" ->
        {podb2, _} = Map.get(graph, "B2")
        {podb3, _} = Map.get(graph, "B3", {nil, nil})
        {podb4, _} = Map.get(graph, "B4", {nil, nil})

        case room do
          "B4" ->
            {[], [], []}

          "B3" ->
            if podb4 == "B" or podb4 == nil,
              do: {[], [], []},
              else: traverse_empty_rooms(graph, room, pod, room_type(room), [room], 0)

          "B2" ->
            if (podb4 == "B" or podb4 == nil) and (podb3 == "B" or podb3 == nil),
              do: {[], [], []},
              else: traverse_empty_rooms(graph, room, pod, room_type(room), [room], 0)

          "B1" ->
            if (podb4 == "B" or podb4 == nil) and (podb3 == "B" or podb3 == nil) and podb2 == "B",
              do: {[], [], []},
              else: traverse_empty_rooms(graph, room, pod, room_type(room), [room], 0)

          _ ->
            traverse_empty_rooms(graph, room, pod, room_type(room), [room], 0)
        end

      "C" ->
        {podc2, _} = Map.get(graph, "C2")
        {podc3, _} = Map.get(graph, "C3", {nil, nil})
        {podc4, _} = Map.get(graph, "C4", {nil, nil})

        case room do
          "C4" ->
            {[], [], []}

          "C3" ->
            if podc4 == "C" or podc4 == nil,
              do: {[], [], []},
              else: traverse_empty_rooms(graph, room, pod, room_type(room), [room], 0)

          "C2" ->
            if (podc4 == "C" or podc4 == nil) and (podc3 == "C" or podc3 == nil),
              do: {[], [], []},
              else: traverse_empty_rooms(graph, room, pod, room_type(room), [room], 0)

          "C1" ->
            if (podc4 == "C" or podc4 == nil) and (podc3 == "C" or podc3 == nil) and podc2 == "C",
              do: {[], [], []},
              else: traverse_empty_rooms(graph, room, pod, room_type(room), [room], 0)

          _ ->
            traverse_empty_rooms(graph, room, pod, room_type(room), [room], 0)
        end

      "D" ->
        {podd2, _} = Map.get(graph, "D2")
        {podd3, _} = Map.get(graph, "D3", {nil, nil})
        {podd4, _} = Map.get(graph, "D4", {nil, nil})

        case room do
          "D4" ->
            {[], [], []}

          "D3" ->
            if podd4 == "D" or podd4 == nil,
              do: {[], [], []},
              else: traverse_empty_rooms(graph, room, pod, room_type(room), [room], 0)

          "D2" ->
            if (podd4 == "D" or podd4 == nil) and (podd3 == "D" or podd3 == nil),
              do: {[], [], []},
              else: traverse_empty_rooms(graph, room, pod, room_type(room), [room], 0)

          "D1" ->
            if (podd4 == "D" or podd4 == nil) and (podd3 == "D" or podd3 == nil) and podd2 == "D",
              do: {[], [], []},
              else: traverse_empty_rooms(graph, room, pod, room_type(room), [room], 0)

          _ ->
            traverse_empty_rooms(graph, room, pod, room_type(room), [room], 0)
        end
    end
  end

  # Find all valid rooms
  def traverse_empty_rooms(graph, room, pod, room_type, visited, curr_count) do
    {_, connected_rooms} = Map.get(graph, room)
    # Find all valid adjacent nodes
    {moves, rooms, visited} =
      Enum.reduce(connected_rooms, {[], [], visited}, fn {next_room, count},
                                                         {moves, rooms, visited} ->
        if next_room in visited do
          {moves, rooms, visited}
        else
          {pod_in_room, _} = Map.get(graph, next_room)

          case pod_in_room do
            "" ->
              case room_type == :hallway and room_type(next_room) == :hallway do
                true ->
                  {moves, rooms ++ [{next_room, curr_count + count}], visited ++ [next_room]}

                false ->
                  if can_pod_enter_room(graph, pod, next_room) do
                    {moves ++ [{next_room, curr_count + count}],
                     rooms ++ [{next_room, curr_count + count}], visited ++ [next_room]}
                  else
                    {moves, rooms ++ [{next_room, curr_count + count}], visited ++ [next_room]}
                  end
              end

            _ ->
              {moves, rooms, visited ++ [next_room]}
          end
        end
      end)

    # Find subsequent non-adjacent nodes
    {further_moves, further_rooms, further_visited} =
      Enum.reduce(rooms, {[], [], visited}, fn {next_room, count}, {moves, rooms, visited} ->
        {new_moves, new_rooms, new_visited} =
          traverse_empty_rooms(graph, next_room, pod, room_type, visited, count)

        {moves ++ new_moves, rooms ++ new_rooms, new_visited}
      end)

    # Return combined
    {moves ++ further_moves, rooms ++ further_rooms, further_visited}
  end

  # check to see if the amphipod is allowed to enter room
  def can_pod_enter_room(graph, pod, room) do
    case pod do
      "A" ->
        case room do
          r when r in ["B1", "B2", "B3", "B4", "C1", "C2", "C3", "C4", "D1", "D2", "D3", "D4"] ->
            false

          "A3" ->
            {poda4, _} = Map.get(graph, "A4", {nil, nil})
            poda4 == "A" or poda4 == nil

          "A2" ->
            {poda3, _} = Map.get(graph, "A3", {nil, nil})
            {poda4, _} = Map.get(graph, "A4", {nil, nil})
            (poda3 == "A" or poda3 == nil) and (poda4 == "A" or poda4 == nil)

          "A1" ->
            {poda2, _} = Map.get(graph, "A2")
            {poda3, _} = Map.get(graph, "A3", {nil, nil})
            {poda4, _} = Map.get(graph, "A4", {nil, nil})
            poda2 == "A" and (poda3 == "A" or poda3 == nil) and (poda4 == "A" or poda4 == nil)

          _ ->
            true
        end

      "B" ->
        case room do
          r when r in ["A1", "A2", "A3", "A4", "C1", "C2", "C3", "C4", "D1", "D2", "D3", "D4"] ->
            false

          "B3" ->
            {podb4, _} = Map.get(graph, "B4", {nil, nil})
            podb4 == "B" or podb4 == nil

          "B2" ->
            {podb3, _} = Map.get(graph, "B3", {nil, nil})
            {podb4, _} = Map.get(graph, "B4", {nil, nil})
            (podb3 == "B" or podb3 == nil) and (podb4 == "B" or podb4 == nil)

          "B1" ->
            {podb2, _} = Map.get(graph, "B2")
            {podb3, _} = Map.get(graph, "B3", {nil, nil})
            {podb4, _} = Map.get(graph, "B4", {nil, nil})
            podb2 == "B" and (podb3 == "B" or podb3 == nil) and (podb4 == "B" or podb4 == nil)

          _ ->
            true
        end

      "C" ->
        case room do
          r when r in ["A1", "A2", "A3", "A4", "B1", "B2", "B3", "B4", "D1", "D2", "D3", "D4"] ->
            false

          "C3" ->
            {podc4, _} = Map.get(graph, "C4", {nil, nil})
            podc4 == "C" or podc4 == nil

          "C2" ->
            {podc3, _} = Map.get(graph, "C3", {nil, nil})
            {podc4, _} = Map.get(graph, "C4", {nil, nil})
            (podc3 == "C" or podc3 == nil) and (podc4 == "C" or podc4 == nil)

          "C1" ->
            {podc2, _} = Map.get(graph, "C2")
            {podc3, _} = Map.get(graph, "C3", {nil, nil})
            {podc4, _} = Map.get(graph, "C4", {nil, nil})
            podc2 == "C" and (podc3 == "C" or podc3 == nil) and (podc4 == "C" or podc4 == nil)

          _ ->
            true
        end

      "D" ->
        case room do
          r when r in ["A1", "A2", "A3", "A4", "B1", "B2", "B3", "B4", "C1", "C2", "C3", "C4"] ->
            false

          "D3" ->
            {podd4, _} = Map.get(graph, "D4", {nil, nil})
            podd4 == "D" or podd4 == nil

          "D2" ->
            {podd3, _} = Map.get(graph, "D3", {nil, nil})
            {podd4, _} = Map.get(graph, "D4", {nil, nil})
            (podd3 == "D" or podd3 == nil) and (podd4 == "D" or podd4 == nil)

          "D1" ->
            {podd2, _} = Map.get(graph, "D2")
            {podd3, _} = Map.get(graph, "D3", {nil, nil})
            {podd4, _} = Map.get(graph, "D4", {nil, nil})
            podd2 == "D" and (podd3 == "D" or podd3 == nil) and (podd4 == "D" or podd4 == nil)

          _ ->
            true
        end
    end
  end

  def room_type(room) do
    case room do
      r
      when r in [
             "A1",
             "A2",
             "A3",
             "A4",
             "B1",
             "B2",
             "B3",
             "B4",
             "C1",
             "C2",
             "C3",
             "C4",
             "D1",
             "D2",
             "D3",
             "D4"
           ] ->
        :room

      _ ->
        :hallway
    end
  end

  def energy(amphipod) do
    case amphipod do
      "A" -> 1
      "B" -> 10
      "C" -> 100
      "D" -> 1000
    end
  end
end
