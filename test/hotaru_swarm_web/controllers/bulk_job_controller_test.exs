defmodule HotaruSwarmWeb.BulkJobControllerTest do
  use HotaruSwarmWeb.ConnCase
  
  alias Plug.Conn
  alias HotaruSwarm.Bulk

  @in_progress_job %{
    output: %{},
    output_format: "application/fhir+ndjson",
    request: "/fhir/$export",
    status: "in_progress",
    type: "export"
  }

  @completed_job %{
    output_format: "application/fhir+ndjson",
    request: "/fhir/$export",
    status: "completed",
    type: "export",
    output: %{
      "1" => %{
        "error" => "error",
        "query" => "http://hapi.fhir.org/R/Consent", 
        "result" => []
      }, 
      "2" => %{
        "query" => "http://hapi.fhir.org/baseR4/Patient", 
        "result" => [
          %{
            "key1" => "value1",
            "key2" => "value2"
          },
          %{
            "key1" => "value1",
            "key2" => "value2"
          }
        ]
      }
    }
  }
  
  def fixture(:in_progress_bulk_job) do
    {:ok, bulk_job} = Bulk.create_bulk_job(@in_progress_job)
    bulk_job
  end

  def fixture(:completed_bulk_job) do
    {:ok, bulk_job} = Bulk.create_bulk_job(@completed_job)
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
      assert response(conn, 202)
      [location] = Conn.get_resp_header(conn, "content-location")
    
      conn = get(conn, URI.parse(location).path)
      assert conn.status == 202 or conn.status == 200
    end

    test "renders errors when data is invalid", %{conn: conn} do
      request = "/fhir/$export?bad=params"
      conn = get(conn, request)
      assert json_response(conn, 400)["errors"] != %{}
    end
  end

  describe "completed bulk_job" do
    setup [:create_completed_bulk_job]

    test "get chosen completed bulk_job", %{conn: conn, bulk_job: bulk_job} do
      conn = get(conn, "/bulk_jobs/#{bulk_job.id}")
      assert %{
        "error" => [_],
        "output" => [
          %{
            "count" => 2,
            "url" => file_url
          }
        ]
      } = json_response(conn, 200)
      

      conn = conn 
        |> recycle()
        |> put_req_header("accept", "application/fhir+ndjson")
        |> get(file_url)
      assert 200 == conn.status
      assert 2 == conn.resp_body |> String.split("\n") |> length
    end
  end

  describe "delete bulk_job" do
    setup [:create_in_progress_bulk_job]

    test "deletes chosen bulk_job", %{conn: conn, bulk_job: bulk_job} do
      conn = delete(conn, Routes.bulk_job_path(conn, :delete, bulk_job))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.bulk_job_path(conn, :show, bulk_job))
      end
    end
  end

  defp create_in_progress_bulk_job(_) do
    bulk_job = fixture(:in_progress_bulk_job)
    {:ok, bulk_job: bulk_job}
  end

  defp create_completed_bulk_job(_) do
    bulk_job = fixture(:completed_bulk_job)
    {:ok, bulk_job: bulk_job}
  end
end
