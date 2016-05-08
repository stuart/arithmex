defmodule Arithmex.PuzzleGeneratorTest do
  use ExUnit.Case
  use EQC.ExUnit

  test "Can generate a puzzle" do
    assert %Arithmex.Puzzle{} = Arithmex.PuzzleGenerator.generate(3)
  end

  test "It assigns numbers in the correct proportions" do
     puzzle = Arithmex.PuzzleGenerator.generate(3)
     assert length(puzzle.numbers) == 6
     assert [_,_,_] = Enum.filter(puzzle.numbers, fn(n) -> n > 10 end)
     puzzle = Arithmex.PuzzleGenerator.generate(0)
     assert [] = Enum.filter(puzzle.numbers, fn(n) -> n > 10 end)
  end

  property "It assigns a solution to the puzzle" do
    forall({n_large, rand} <- {valid_n_large, bool()}) do
      puzzle = Arithmex.PuzzleGenerator.generate(n_large, rand)
      case puzzle.solution do
        :no_solution -> true
        _ -> ensure puzzle.target == Arithmex.Parser.parse(puzzle.solution)
      end
    end
  end

  property "It assigns a target number between 100 and 1000" do
    forall({n_large, rand} <- {valid_n_large, bool()}) do
      target = Arithmex.PuzzleGenerator.generate(n_large, rand).target
      ensure target > 100
      ensure target < 1000
    end
  end

  def valid_n_large do
    such_that n <- nat(), do: n <= 4
  end
end
