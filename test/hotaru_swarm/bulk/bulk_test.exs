defmodule HotaruSwarm.BulkTest do
  use HotaruSwarm.DataCase

  alias HotaruSwarm.Bulk

  describe "bulk_job" do
    alias HotaruSwarm.Bulk.BulkJob

    @valid_attrs %{count: 42, output: "some output", output_format: "some output_format", request: "some request", status: "some status", type: "some type"}
    @update_attrs %{count: 43, output: "some updated output", output_format: "some updated output_format", request: "some updated request", status: "some updated status", type: "some updated type"}
    @invalid_attrs %{count: nil, output: nil, output_format: nil, request: nil, status: nil, type: nil}

    def bulk_job_fixture(attrs \\ %{}) do
      {:ok, bulk_job} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Bulk.create_bulk_job()

      bulk_job
    end

    test "list_bulk_job/0 returns all bulk_job" do
      bulk_job = bulk_job_fixture()
      assert Bulk.list_bulk_job() == [bulk_job]
    end

    test "get_bulk_job!/1 returns the bulk_job with given id" do
      bulk_job = bulk_job_fixture()
      assert Bulk.get_bulk_job!(bulk_job.id) == bulk_job
    end

    test "create_bulk_job/1 with valid data creates a bulk_job" do
      assert {:ok, %BulkJob{} = bulk_job} = Bulk.create_bulk_job(@valid_attrs)
      assert bulk_job.count == 42
      assert bulk_job.output == "some output"
      assert bulk_job.output_format == "some output_format"
      assert bulk_job.request == "some request"
      assert bulk_job.status == "some status"
      assert bulk_job.type == "some type"
    end

    test "create_bulk_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Bulk.create_bulk_job(@invalid_attrs)
    end

    test "update_bulk_job/2 with valid data updates the bulk_job" do
      bulk_job = bulk_job_fixture()
      assert {:ok, %BulkJob{} = bulk_job} = Bulk.update_bulk_job(bulk_job, @update_attrs)
      assert bulk_job.count == 43
      assert bulk_job.output == "some updated output"
      assert bulk_job.output_format == "some updated output_format"
      assert bulk_job.request == "some updated request"
      assert bulk_job.status == "some updated status"
      assert bulk_job.type == "some updated type"
    end

    test "update_bulk_job/2 with invalid data returns error changeset" do
      bulk_job = bulk_job_fixture()
      assert {:error, %Ecto.Changeset{}} = Bulk.update_bulk_job(bulk_job, @invalid_attrs)
      assert bulk_job == Bulk.get_bulk_job!(bulk_job.id)
    end

    test "delete_bulk_job/1 deletes the bulk_job" do
      bulk_job = bulk_job_fixture()
      assert {:ok, %BulkJob{}} = Bulk.delete_bulk_job(bulk_job)
      assert_raise Ecto.NoResultsError, fn -> Bulk.get_bulk_job!(bulk_job.id) end
    end

    test "change_bulk_job/1 returns a bulk_job changeset" do
      bulk_job = bulk_job_fixture()
      assert %Ecto.Changeset{} = Bulk.change_bulk_job(bulk_job)
    end
  end
end
