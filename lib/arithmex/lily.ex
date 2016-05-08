defmodule Arithmex.Lily do
  alias Arithmex.Puzzle
  @moduledoc """
    Solves "numbers" puzzles.

    If you are wondering about the name, you need to watch SBS more.
  """

  @doc """
    Solves a numbers problem.
  """
  def solve(puzzle) do
    {:ok, solutions} = Agent.start_link fn -> [] end

    Enum.each puzzle.numbers, fn(m) ->
      next_numbers = Enum.filter(puzzle.numbers, fn(e) -> e != m end)
      do_solve(%{numbers: next_numbers, total: m, target: puzzle.target}, [m], solutions)
    end

    solution = case Agent.get(solutions, fn list -> list end) do
      [] -> :no_solution
      list -> Enum.random(list) |> solution_string
    end

    %Puzzle{puzzle | solution: solution}
  end

  defp do_solve(%{total: t, target: t}, path, solutions) do
    Agent.update(solutions, fn list -> [path | list] end)
  end

  defp do_solve(%{numbers: []}, _, _) do
  end

  defp do_solve(%{numbers: numbers, total: total, target: target}, path, solutions) do
    Enum.each numbers, fn(m) ->
      next_numbers = Enum.filter(numbers, fn(e) -> e != m end)
      do_solve(%{numbers: next_numbers, total: total + m, target: target}, [m | [ "+" | path]], solutions)
      do_solve(%{numbers: next_numbers, total: total - m, target: target}, [m | [ "-" | path]], solutions)
      if total != 1 and m != 1 do
        do_solve(%{numbers: next_numbers, total: total * m, target: target}, [m | [ "*" | path]], solutions)
      end
      if rem(total, m) == 0 and m != 1 do
        do_solve(%{numbers: next_numbers, total: div(total,m), target: target}, [m | [ "/" | path]], solutions)
      end
    end
  end

  # Converts a list of numbers and operations into a list, wrapping in parens where needed.
  defp solution_string list do
    solution_string(Enum.reverse(list), "", false, 0)
  end

  defp solution_string([], result, _, count) do
    String.duplicate("(",count) <> result
  end

  defp solution_string([int | list], result, additive, count) when is_integer(int) do
    solution_string(list, result <> "#{int}", additive, count)
  end

  defp solution_string(["*" | list], result, true, count) do
    solution_string(list, result <> ")*", false, count + 1)
  end

  defp solution_string(["*" | list], result, false, count) do
    solution_string(list, result <> "*", false, count)
  end

  defp solution_string(["+" | list], result, _, count) do
    solution_string(list, result <> "+", true, count)
  end

  defp solution_string(["-" | list], result, _, count) do
    solution_string(list, result <> "-", true, count)
  end

  defp solution_string(["/" | list], result, true, count) do
    solution_string(list, result <> ")/", false, count + 1)
  end

  defp solution_string(["/" | list], result, false, count) do
    solution_string(list, result <> "/", false, count)
  end
end
