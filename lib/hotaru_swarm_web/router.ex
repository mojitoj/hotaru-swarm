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

  pipeline :file do
    plug :accepts, ["ndjson"]
  end

  scope "/", HotaruSwarmWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/fhir", HotaruSwarmWeb do
    pipe_through :api
    get "/$export", BulkJobController, :create
  end

  scope "/fhir/Patient", HotaruSwarmWeb do
    pipe_through :api
    get "/$export", BulkJobController, :create
  end

  scope "/bulk_jobs", HotaruSwarmWeb do
    pipe_through :api
    get "/:id", BulkJobController, :show
    get "/", BulkJobController, :index
    delete "/:id", BulkJobController, :delete
  end

  scope "/files", HotaruSwarmWeb do
    pipe_through :file
    get "/:job_id/:file_id", BulkJobController, :show_file
  end
end
