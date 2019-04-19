defmodule HotaruSwarm.Bulk.BulkJob do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "bulk_job" do
    field :output, :map
    field :output_format, :string
    field :request, :string
    field :status, :string
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(bulk_job, attrs) do
    bulk_job
    |> cast(attrs, [:request, :type, :output_format, :status, :output])
    |> validate_required([:request, :type, :output_format, :status])
  end
end
