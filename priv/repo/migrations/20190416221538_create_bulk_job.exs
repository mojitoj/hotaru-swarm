defmodule HotaruSwarm.Repo.Migrations.CreateBulkJob do
  use Ecto.Migration

  def change do
    create table(:bulk_job, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :request, :string
      add :type, :string
      add :output_format, :string
      add :status, :string
      add :count, :integer
      add :output, :text

      timestamps()
    end

  end
end
