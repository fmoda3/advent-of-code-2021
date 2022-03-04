defmodule AdventOfCode.Day21 do
  # The possible rolls, with the amount of times that roll can happen, on a given turn
  @quantum_rolls %{3 => 1, 4 => 3, 5 => 6, 6 => 7, 7 => 6, 8 => 3, 9 => 1}

  def part1(args) do
    args
    |> parse_input()
    |> play_regular()
    |> (fn {players, dice_count} ->
          {_, {_, losing_score}} = losing_player(players)
          dice_count * losing_score
        end).()
  end

  def part2(args) do
    args
    |> parse_input()
    |> play_quantum()
    |> Enum.max()
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_player/1)
    |> Enum.into(%{})
  end

  def parse_player(line) do
    split =
      line
      |> String.split(" ", trim: true)

    num =
      Enum.at(split, 1)
      |> String.to_integer()

    pos =
      Enum.at(split, 4)
      |> String.to_integer()

    {num, {pos, 0}}
  end

  def play_regular(players), do: play_regular(players, 1, 1, 0)

  def play_regular(players, curr_player, dice, dice_count) do
    {curr_space, curr_score} = Map.get(players, curr_player)
    dice_rolls = Enum.sum([dice, dice + 1, dice + 2])
    new_space = mod_1(curr_space + dice_rolls, 10)
    new_score = curr_score + new_space
    players = Map.put(players, curr_player, {new_space, new_score})

    cond do
      new_score >= 1000 ->
        {players, dice_count + 3}

      true ->
        next_player = mod_1(curr_player + 1, Enum.count(players))
        next_dice = mod_1(dice + 3, 100)
        play_regular(players, next_player, next_dice, dice_count + 3)
    end
  end

  def play_quantum(players) do
    {pos_1, score_1} = Map.get(players, 1)
    {pos_2, score_2} = Map.get(players, 2)
    states = Map.put(%{}, {pos_1, score_1, pos_2, score_2}, 1)
    play_quantum(states, 1, 2, 0, 0)
  end

  def play_quantum(states, _, _, p1wins, p2wins) when states == %{}, do: [p1wins, p2wins]

  def play_quantum(states, curr_player, next_player, p1wins, p2wins) do
    {new_states, new_p1wins, new_p2wins} =
      Enum.reduce(states, {%{}, p1wins, p2wins}, fn {{pos_1, score_1, pos_2, score_2}, count},
                                                    {new_states, new_p1wins, new_p2wins} ->
        case curr_player do
          1 ->
            {player1_states, player_wins} = play_quantum_player(pos_1, score_1, count)

            {combine_player_1_states(player1_states, new_states, pos_2, score_2),
             new_p1wins + player_wins, new_p2wins}

          2 ->
            {player2_states, player_wins} = play_quantum_player(pos_2, score_2, count)

            {combine_player_2_states(player2_states, new_states, pos_1, score_1), new_p1wins,
             new_p2wins + player_wins}
        end
      end)

    play_quantum(new_states, next_player, curr_player, new_p1wins, new_p2wins)
  end

  def play_quantum_player(pos, score, count) do
    Enum.reduce(@quantum_rolls, {%{}, 0}, fn {d, dcount}, {new_states, new_wins} ->
      new_pos = mod_1(pos + d, 10)
      new_score = score + new_pos
      add_count = count * dcount

      cond do
        new_score >= 21 ->
          {new_states, new_wins + add_count}

        true ->
          {Map.update(new_states, {new_pos, new_score}, add_count, fn x -> x + add_count end),
           new_wins}
      end
    end)
  end

  def combine_player_1_states(player_states, states, pos_2, score_2) do
    Enum.reduce(player_states, states, fn {{new_pos, new_score}, count}, new_states ->
      Map.update(new_states, {new_pos, new_score, pos_2, score_2}, count, fn x -> x + count end)
    end)
  end

  def combine_player_2_states(player_states, states, pos_1, score_1) do
    Enum.reduce(player_states, states, fn {{new_pos, new_score}, count}, new_states ->
      Map.update(new_states, {pos_1, score_1, new_pos, new_score}, count, fn x -> x + count end)
    end)
  end

  def losing_player(players) do
    players
    |> Enum.find(fn {_, {_, score}} -> score < 1000 end)
  end

  def mod_1(m, n), do: rem(m - 1, n) + 1
end
