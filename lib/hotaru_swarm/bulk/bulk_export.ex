defmodule HotaruSwarm.Bulk.BulkExport do
    require Logger

    alias HotaruSwarm.Bulk

    @all_fhir_resource_types Application.get_env(:hotaru_swarm, HotaruSwarm.Bulk.BulkExport)[:exportable_fhir_resources]
    @headers ["Accept": "application/json; charset=utf-8"]

    @redacted_null_flavor %{
        "system" => "http://terminology.hl7.org/CodeSystem/v3-NullFlavor",
        "code" => "MSK"
    }
    
    def fulfill(bulk_job, types, type_filters, since) do
        results = query_urls(types, type_filters, since) |> Enum.map(&invoke_fhir_query(&1))

        job_status = if Enum.any?(results, &(!is_nil &1["error"])) do "completed_with_errors" else "completed" end
        
        Bulk.update_bulk_job(bulk_job, %{status: job_status, output: process_results(results)})
    end

    def invoke_fhir_query(query) do 
        Logger.info  "FHIR Query: #{query}"
        request_id = Ecto.UUID.generate
        case get_page(query) do
            {:ok, results} -> 
                %{
                    request_id => %{query: query, result: results}
                }
            {:error, error} -> 
                %{
                    request_id => %{query: query, result: [], error: error}
                }
        end
    end

    def get_page(query) when is_nil(query), do: {:ok, []}
    def get_page(query) do
        Logger.info  "\t  Sub-Query: #{query}"
        case HTTPoison.get(query, @headers) do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
                json_body = Jason.decode!(body)
                case get_page(get_next_page_link(json_body)) do
                    {:ok, next_page} -> {:ok, process_fhir_response_body(json_body) ++ next_page}
                    {:error, error} -> {:error, error}
                end
            _ -> 
                {:error, "error fetching #{query}"} 
        end
    end

    def get_next_page_link(json_body) do
        next_links = json_body["link"]
            |> Enum.filter(&("next" == Map.get(&1, "relation")))
        case next_links do
            [] -> nil
            _ -> Enum.at(next_links, 0)["url"]
        end
    end

    def process_fhir_response_body(json_body) do
        entries = json_body["entry"] || [] 
        entries 
          |> Enum.map(&(&1["resource"]))
          |> Enum.map(&(apply_content_filters(&1, nil)))
    end

    def apply_content_filters(_resources, _filters) do
        filters = ["Patient.name"]
    end

    def apply_content_filter(resources, filter) do
        [resource_type|path] = String.split(filter, ".")
        resources
          |> Enum.filter(&(&1["resourceType"]==resource_type))
          |> Enum.map(&(redact(&1, path)))
    end

    def redact(resource, path) do
        unless get_in(resource, path) do
            put_in(resource, path, @redacted_null_flavor)
        else
            resource
        end
    end

    def process_results(results) do
        results
        |> Enum.reduce(%{}, &(Map.merge(&2, &1)))
    end

    def query_urls(types, type_filters_string, since) do
        all_types = all_types(types)
        type_filters = parse_type_filters(type_filters_string)
        applicable_type_filters = Enum.filter(type_filters, &(&1.resource_name in all_types))
        wildcard_filters = Enum.filter(type_filters, &(&1.resource_name ==="*")) ++ since_filter(since)

        all_unfiltered_types = all_types
            |> Enum.filter(&(&1 not in filtered_types(type_filters)))
            |> Enum.map(&parse_type_filter/1)

        all_paths = applicable_type_filters ++ all_unfiltered_types
            |> apply_wild_card_filters_to_paths(wildcard_filters)
        fhir_servers = Application.get_env(:hotaru_swarm, HotaruSwarm.Bulk.BulkExport)[:fhir_backends]
        for fhir_base <- fhir_servers, path <- all_paths, do: "#{fhir_base}/#{path}"
    end

    def since_filter(since) when is_nil(since), do: []
    def since_filter(since) do
        [
            %{
                resource_name: "*",
                filter_query: "_lastUpdated=gt#{since}"
            }
        ]
    end

    
    def filtered_types(type_filters) do 
        type_filters |> Enum.map(&(&1.resource_name))
    end

    def apply_wild_card_filters_to_paths(paths, wildcard_type_filters) do
        paths |> Enum.map(&(apply_wild_card_filters_to_path(&1, wildcard_type_filters)))
    end

    def apply_wild_card_filters_to_path(path, wildcard_type_filters) do
        wildcard_type_filters_string = wildcard_type_filters
            |> Enum.map(&(&1.filter_query))
            |> Enum.join("&")
        add_filter_to_path(path, wildcard_type_filters_string)
    end

    def add_filter_to_path(path, filter_string) when is_nil(filter_string) or filter_string==="" do
        if (is_nil(path.filter_query)) do
            "#{path.resource_name}"
        else
            "#{path.resource_name}?#{path.filter_query}"
        end
    end

    def add_filter_to_path(path, filter_string) do
        if (is_nil(path.filter_query)) do
            "#{path.resource_name}?#{filter_string}"
        else
            "#{path.resource_name}?#{path.filter_query}&#{filter_string}"
        end
    end

    def parse_type_filters(type_filters_string) when is_nil(type_filters_string) or type_filters_string==="", do: []
    def parse_type_filters(type_filters_string) do
        type_filters_string 
            |> String.split(",")
            |> Enum.map(&parse_type_filter/1)
    end

    def parse_type_filter(type_filter_string) do 
        type_filter_chunks = String.split(type_filter_string, "?")
        %{
            resource_name: Enum.at(type_filter_chunks, 0),
            filter_query: Enum.at(type_filter_chunks, 1)
        }
    end
    
    def all_types(types) when types==="" or is_nil(types), do: @all_fhir_resource_types
    
    def all_types(types), do: String.split(types, ",")
end
