defmodule Arithmex.Api.PuzzleController do
  use Arithmex.Web, :controller

  alias Arithmex.Puzzle

  def index(conn, _params) do
    render conn, "puzzle.json", %{puzzle: Arithmex.Puzzle.generate}
  end
end
