defmodule HotaruSwarmWeb.BulkJobController do
  use HotaruSwarmWeb, :controller

  alias HotaruSwarm.Bulk
  alias HotaruSwarm.Bulk.BulkJob
  alias HotaruSwarm.Bulk.BulkExport

  action_fallback HotaruSwarmWeb.FallbackController

  @export_parameters ["_outputFormat", "_since", "_type", "_typeFilter"]

  def index(conn, _params) do
    bulk_job = Bulk.list_bulk_job()
    render(conn, "index.json", bulk_job: bulk_job)
  end

  def create(conn, params) do
    with {:ok, bulk_job_params} <- to_bulk_export_job_parameters(conn, params),
      {:ok, %BulkJob{} = bulk_job} <- Bulk.create_bulk_job(bulk_job_params) do
      
      Task.Supervisor.async_nolink(HotaruSwarm.TaskSupervisor, fn ->
        :timer.sleep(2000)
        BulkExport.fulfill(bulk_job, params["_type"], params["_typeFilter"], params["_since"])
      end)

      conn
      |> put_status(:accepted)
      |> put_resp_header("location", "#{HotaruSwarmWeb.Router.Helpers.url(conn)}/bulk_jobs/#{bulk_job.id}")
      |> json(%{})
    end
  end

  def to_bulk_export_job_parameters(conn, params) do
    if Enum.all?(Map.keys(params), &(&1 in @export_parameters)) do
      {:ok, 
        %{
          request: full_request(conn),
          status: "in_progress",
          type: "export",
          output_format: "application/fhir+ndjson"
        }
      }
    else
      {:error,
       %{
         error: :invalid_parameter,
         error_message: "Accepted parameters are #{Enum.join(@export_parameters, ",")}."
       }}
    end
  end

  defp full_request(conn) do
    if conn.query_string=="" do
      conn.request_path
    else
      "#{conn.request_path}?#{conn.query_string}"
    end
  end

  def show(conn, %{"id" => id}) do
    bulk_job = Bulk.get_bulk_job!(id)
    show_bulk_job(conn, bulk_job)
  end

  def show_bulk_job(conn, %{status: "completed"}=bulk_job), do: render(conn, "show.json", bulk_job: bulk_job)
  def show_bulk_job(conn, %{status: "error"}=bulk_job), do: render(conn, "show.json", bulk_job: bulk_job)
  def show_bulk_job(conn, bulk_job) do
    conn
    |> put_status(:accepted)
    |> put_resp_header("x-progress", bulk_job.status)
  end

  def show_file(conn, %{"job_id" => job_id, "file_id" => file_id}) do
    bulk_job = Bulk.get_bulk_job!(job_id)
    conn
    |> put_resp_header("content-type", bulk_job.output_format)
    |> render("show-file.txt", bulk_job: bulk_job, file_id: file_id)
  end

  def delete(conn, %{"id" => id}) do
    bulk_job = Bulk.get_bulk_job!(id)

    with {:ok, %BulkJob{}} <- Bulk.delete_bulk_job(bulk_job) do
      send_resp(conn, :no_content, "")
    end
  end
end
