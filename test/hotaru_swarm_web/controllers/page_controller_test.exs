defmodule HotaruSwarmWeb.PageControllerTest do
  use HotaruSwarmWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "mountPoint"
  end
end
