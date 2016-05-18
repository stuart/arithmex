defmodule Arithmex.Api.PuzzleView do
  use Arithmex.Web, :view

  def render "puzzle.json", %{puzzle: puzzle} do
    %{ numbers: puzzle.numbers,
       target: puzzle.target,
       n_large: puzzle.n_large,
       total: 0,
       solution: [],
       time: 30,
       id: 1
      }
  end
end
