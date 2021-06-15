defmodule CacheWeb.CacheController do
  use CacheWeb, :controller

  alias Cache.LruCache

  def get(conn, %{"key" => key}) do
    result = %{
      value: LruCache.get(key)
    }

    json(conn, result)
  end

  def get(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> put_view(CacheWeb.ErrorView)
    |> render(:"400")
  end

  def put(conn, %{"key" => key, "value" => value}) do
    LruCache.put(key, value)
    json(conn, :ok)
  end

  def put(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> put_view(CacheWeb.ErrorView)
    |> render(:"400")
  end
end
