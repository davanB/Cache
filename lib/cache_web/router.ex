defmodule CacheWeb.Router do
  use CacheWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/cache", CacheWeb do
    pipe_through :api

    get "/get", CacheController, :get
    put "/put", CacheController, :put
  end
end
