defmodule Arithmex.PageController do
  use Arithmex.Web, :controller

  def index(conn, _params) do
    puzzle = Arithmex.Puzzle.generate
    render conn, "index.html", %{puzzle: puzzle}
  end
end
