defmodule HotaruSwarm.Bulk.BulkExport do
    require Logger

    alias HotaruSwarm.Bulk

    @all_fhir_resource_types Application.get_env(:hotaru_swarm, HotaruSwarm.Bulk.BulkExport)[:exportable_fhir_resources]
    @headers ["Accept": "application/json; charset=utf-8"]

    
    def fulfill(bulk_job, types, type_filters, since) do
        results = query_urls(types, type_filters, since) |> Enum.map(&invoke_fhir_query(&1))

        job_status = if Enum.any?(results, &(!is_nil &1["error"])) do "completed_with_errors" else "completed" end
        
        Bulk.update_bulk_job(bulk_job, %{status: job_status, output: process_results(results)})
    end

    def invoke_fhir_query(query) do 
        Logger.info  "FHIR Query: #{query}"
        request_id = Ecto.UUID.generate
        case HTTPoison.get(query, @headers) do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
                %{
                    request_id => %{query: query, result: process_fhir_response_body(body)}
                }
            _ -> 
                %{
                    request_id => %{query: query, result: [], error: "error"}
                }
        end
    end

    def process_fhir_response_body(body) do
        bundle = Jason.decode!(body)
        entries = bundle["entry"] || [] 
        entries |> Enum.map(&(&1["resource"]))
    end

    def process_results(results) do
        results
        |> Enum.reduce(%{}, &(Map.merge(&2, &1)))
    end

    def query_urls(types, type_filters, _since) do
        all_types = all_types(types)
        all_type_filters = Enum.filter(all_type_filters(type_filters), &(Enum.at(String.split(&1,"?"), 0) in all_types))

        filtered_types = filtered_types(all_type_filters)
        all_types = Enum.filter(all_types, &(&1 not in filtered_types))

        all_paths = all_type_filters ++ all_types
        fhir_servers = Application.get_env(:hotaru_swarm, HotaruSwarm.Bulk.BulkExport)[:fhir_backends]
        for fhir_base <- fhir_servers, path <- all_paths, do: "#{fhir_base}/#{path}"
    end
    
    def filtered_types(all_type_filters) do 
        all_type_filters |> Enum.map(&(Enum.at(String.split(&1, "?"),0)))
    end

    def all_type_filters(type_filters) when type_filters==="" or is_nil(type_filters), do: []
    def all_type_filters(type_filters), do: String.split(type_filters, ",")
    def all_types(types) when types==="" or is_nil(types), do: @all_fhir_resource_types
    def all_types(types), do: String.split(types, ",")
end
