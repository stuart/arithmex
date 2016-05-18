defmodule Arithmex.Api.PuzzleView do
  use Arithmex.Web, :view

  def render "puzzle.json", %{puzzle: puzzle} do
    %{ numbers: number_map(puzzle.numbers),
       target: puzzle.target,
       n_large: puzzle.n_large,
       total: 0,
       solution: [],
       time: 30,
       id: 1
      }
  end

  def number_map numbers do
    {map, acc} = Enum.map_reduce(numbers, 0, fn(n, i) -> {(%{id: i, number: n}), i+1} end)
    map
  end
end
