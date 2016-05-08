defmodule Arithmex.Puzzle do
  defstruct numbers: [], target: 0, solution: "", n_large: 0, guaranteed_solution: false

  def generate do
    generate(:crypto.rand_uniform(0,4))
  end

  def generate(n_large) do
    Arithmex.PuzzleGenerator.generate(n_large, true)
  end

  def check_solution puzzle, solution do
    Arithmex.Parser.parse(solution) == puzzle.target
  end
end
