defmodule HotaruSwarm.Bulk do
  @moduledoc """
  The Bulk context.
  """

  import Ecto.Query, warn: false
  alias HotaruSwarm.Repo

  alias HotaruSwarm.Bulk.BulkJob

  @doc """
  Returns the list of bulk_job.

  ## Examples

      iex> list_bulk_job()
      [%BulkJob{}, ...]

  """
  def list_bulk_job do
    Repo.all(BulkJob)
  end

  @doc """
  Gets a single bulk_job.

  Raises `Ecto.NoResultsError` if the Bulk job does not exist.

  ## Examples

      iex> get_bulk_job!(123)
      %BulkJob{}

      iex> get_bulk_job!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bulk_job!(id), do: Repo.get!(BulkJob, id)

  @doc """
  Creates a bulk_job.

  ## Examples

      iex> create_bulk_job(%{field: value})
      {:ok, %BulkJob{}}

      iex> create_bulk_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bulk_job(attrs \\ %{}) do
    %BulkJob{}
    |> BulkJob.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a bulk_job.

  ## Examples

      iex> update_bulk_job(bulk_job, %{field: new_value})
      {:ok, %BulkJob{}}

      iex> update_bulk_job(bulk_job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bulk_job(%BulkJob{} = bulk_job, attrs) do
    bulk_job
    |> BulkJob.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a BulkJob.

  ## Examples

      iex> delete_bulk_job(bulk_job)
      {:ok, %BulkJob{}}

      iex> delete_bulk_job(bulk_job)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bulk_job(%BulkJob{} = bulk_job) do
    Repo.delete(bulk_job)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bulk_job changes.

  ## Examples

      iex> change_bulk_job(bulk_job)
      %Ecto.Changeset{source: %BulkJob{}}

  """
  def change_bulk_job(%BulkJob{} = bulk_job) do
    BulkJob.changeset(bulk_job, %{})
  end
end
