defmodule Arithmex.PageView do
  use Arithmex.Web, :view

  def solution_html puzzle do
    do_solution_html(puzzle.solution)
  end

  defp do_solution_html :no_solution do
    "?"
  end

  defp do_solution_html solution do
    solution
    |> String.replace("+", "\u002b")
    |> String.replace("-", "\u2212")
    |> String.replace("*", "\u00d7")
    |> String.replace("/", "\u00f7")
  end
end
