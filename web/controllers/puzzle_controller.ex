defmodule Arithmex.PuzzleController do
  use Arithmex.Web, :controller

  alias Arithmex.Puzzle

  def index(conn, _params) do
    render conn, "index.html", %{}
  end
end
