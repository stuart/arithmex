defmodule Arithmex.PageControllerTest do
  use Arithmex.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Arithmex"
  end
end
