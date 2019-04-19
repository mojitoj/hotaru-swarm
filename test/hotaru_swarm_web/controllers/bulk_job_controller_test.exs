defmodule HotaruSwarmWeb.BulkJobControllerTest do
  use HotaruSwarmWeb.ConnCase

  alias HotaruSwarm.Bulk
  alias HotaruSwarm.Bulk.BulkJob

  @create_attrs %{
    output: %{},
    output_format: "application/fhir+ndjson",
    request: "/fhir/$export",
    status: "in_progress",
    type: "export"
  }
  
  def fixture(:bulk_job) do
    {:ok, bulk_job} = Bulk.create_bulk_job(@create_attrs)
    bulk_job
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/fhir+json")}
  end

  describe "index" do
    test "lists all bulk_job", %{conn: conn} do
      conn = get(conn, "/bulk_jobs/")
      assert json_response(conn, 200) == []
    end
  end

  describe "create bulk_job" do
    test "renders bulk_job when data is valid", %{conn: conn} do
      request = "/fhir/$export?_since=2019-10-11&_outputFormat=application/fhir+ndjson&_type=Patient,MedicationRequest&_typeFilter=MedicationRequest%3Fstatus%3Dactive"
      conn = get(conn, request)
      assert %{"id" => id} = json_response(conn, 202)

      conn = get(conn, "/bulk_jobs/#{id}")

      assert %{
               "id" => _id,
               "output" => _output,
               "output_format" => "application/fhir+ndjson",
               "request" => request,
               "status" => "in_progress",
               "type" => "export"
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      request = "/fhir/$export?bad=params"
      conn = get(conn, request)
      assert json_response(conn, 400)["errors"] != %{}
    end
  end

  describe "delete bulk_job" do
    setup [:create_bulk_job]

    test "deletes chosen bulk_job", %{conn: conn, bulk_job: bulk_job} do
      conn = delete(conn, Routes.bulk_job_path(conn, :delete, bulk_job))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.bulk_job_path(conn, :show, bulk_job))
      end
    end
  end

  defp create_bulk_job(_) do
    bulk_job = fixture(:bulk_job)
    {:ok, bulk_job: bulk_job}
  end
end
