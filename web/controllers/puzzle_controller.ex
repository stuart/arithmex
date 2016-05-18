defmodule Arithmex.PuzzleController do
  use Arithmex.Web, :controller

  alias Arithmex.Puzzle

  def index(conn, _params) do
    puzzle = Puzzle.generate
    render conn, "index.html", %{puzzle: puzzle}
  end
end
