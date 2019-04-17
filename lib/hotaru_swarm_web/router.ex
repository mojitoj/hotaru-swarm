defmodule HotaruSwarmWeb.Router do
  use HotaruSwarmWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HotaruSwarmWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/fhir", HotaruSwarmWeb do
    pipe_through :api
    get "/$export", BulkJobController, :create
  end

  scope "/bulk_jobs", HotaruSwarmWeb do
    pipe_through :api
    get "/:id", BulkJobController, :show
    get "/", BulkJobController, :index
    delete "/:id", BulkJobController, :delete
  end
end
