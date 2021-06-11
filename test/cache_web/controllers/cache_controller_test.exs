defmodule CacheWeb.CacheControllerTest do
  use CacheWeb.ConnCase

  test "get bad request on get if no key", %{conn: conn} do
    params = %{"bad_key" => "not_here"}
    conn = get(conn, Routes.cache_path(conn, :get, params))
    assert json_response(conn, 400) == error_view("400")
  end

  test "get a value not in cache", %{conn: conn} do
    params = %{"key" => "not_here"}
    conn = get(conn, Routes.cache_path(conn, :get, params))
    assert json_response(conn, 200)["value"] == nil
  end

  test "get bad request on put if not key and value", %{conn: conn} do
    params = %{"bad_key" => "not_here", "no_value" => "blah"}
    conn = put(conn, Routes.cache_path(conn, :put, params))
    assert json_response(conn, 400) == error_view("400")
  end

  test "put a value in cache", %{conn: conn} do
    params = %{"key" => "the_key", "value" => "the_value"}
    conn = put(conn, Routes.cache_path(conn, :put, params))
    assert json_response(conn, 200) == "ok"

    params = %{"key" => "the_key"}
    conn = get(conn, Routes.cache_path(conn, :get, params))
    assert json_response(conn, 200)["value"] == "the_value"
  end

  defp error_view(code) do
    CacheWeb.ErrorView.render(code)
    |> Jason.encode!()
    |> Jason.decode!()
  end
end
