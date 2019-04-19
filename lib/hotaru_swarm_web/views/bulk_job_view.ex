defmodule HotaruSwarmWeb.BulkJobView do
  use HotaruSwarmWeb, :view
  alias HotaruSwarmWeb.BulkJobView

  def render("index.json", %{bulk_job: bulk_job}) do
    render_many(bulk_job, BulkJobView, "bulk_job.json")
  end

  def render("show.json", %{bulk_job: bulk_job}) do
    render_one(bulk_job, BulkJobView, "bulk_job.json")
  end

  def render("show-file.txt", %{bulk_job: bulk_job, file_id: file_id}) do
    bulk_job.output
    |>Map.get(file_id)
    |>Map.get("result")
    |>Enum.map(&(Jason.encode! &1))
    |>Enum.join("\n")
  end

  def render("bulk_job.json", %{bulk_job: bulk_job}) do
    %{transactionTime: bulk_job.updated_at,
      request: bulk_job.request,
      requiresAccessToken: false,
      output: render_output(bulk_job),
      error: render_errors(bulk_job)
    }
  end

  def render_output(bulk_job) do 
    (bulk_job.output || %{})
      |> Enum.filter(fn {_, result} -> is_nil result["error"] end)
      |> Enum.map(fn {id, result} -> 
        parsed_query = parse_query(result["query"])
        %{
          type: parsed_query.resource_type,
          source: parsed_query.source,
          query: result["query"],
          url: "/files/#{bulk_job.id}/#{id}",
          count: length result["result"]
        }
      end)
  end
  
  def render_errors(bulk_job) do
    (bulk_job.output || %{})
      |> Enum.filter(fn {_, result} -> !is_nil result["error"] end)
      |> Enum.map(fn {_, result} -> 
        %{
          query: result["query"],
          error: result["error"]
        }
      end)
  end

  def parse_query(query) do
    path_chunks = query |> String.split("/")
    resource_type = path_chunks |> Enum.at(-1) |> String.split("?") |> Enum.at(0)
    source = path_chunks |> Enum.drop(-1) |> Enum.join("/")
    %{
      source: source,
      resource_type: resource_type,
      query: query
    }
  end
end
