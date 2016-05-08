defmodule Arithmex.PuzzleTest do
  use ExUnit.Case

  test "puzzle struct" do
    assert %{target: 0, solution: "", numbers: [], n_large: 0, guaranteed_solution: false} = %Arithmex.Puzzle{}
  end

  test "checking a solution" do
    puzzle = %Arithmex.Puzzle{target: 10, numbers: [1,2,3,4,5,6]}
    assert Arithmex.Puzzle.check_solution(puzzle, "2*3+4")
  end

  test "checking a wrong solution" do
    puzzle = %Arithmex.Puzzle{target: 10, numbers: [1,2,3,4,5,6]}
    refute Arithmex.Puzzle.check_solution(puzzle, "2*3-4")
  end
end
