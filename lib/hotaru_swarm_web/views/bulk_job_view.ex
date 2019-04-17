defmodule HotaruSwarmWeb.BulkJobView do
  use HotaruSwarmWeb, :view
  alias HotaruSwarmWeb.BulkJobView

  def render("index.json", %{bulk_job: bulk_job}) do
    render_many(bulk_job, BulkJobView, "bulk_job.json")
  end

  def render("show.json", %{bulk_job: bulk_job}) do
    render_one(bulk_job, BulkJobView, "bulk_job.json")
  end

  def render("bulk_job.json", %{bulk_job: bulk_job}) do
    %{id: bulk_job.id,
      request: bulk_job.request,
      type: bulk_job.type,
      output_format: bulk_job.output_format,
      status: bulk_job.status,
      count: bulk_job.count,
      output: bulk_job.output}
  end
end
