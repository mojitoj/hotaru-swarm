# Hotaru Swarm
Hotaru Swarm is an experimental implementation of the emerging [FHIR Bulk Data Transfer specifications](https://github.com/smart-on-fhir/fhir-bulk-data-docs/blob/master/export.md), written in Elixir and Phoenix. 

Hotaru Swarm is implemented in the form of a proxy which can be configured to fetch data from one or more FHIR servers.

(*) The name of this project is based on the Japanese word for _firefly_. 

## Features
Currently the following features are supported:

  * `_type`, `_typeFilter`, and `_since` parameters.
  * `$export` operations.
  * `application/fhir+ndjson` format for exported data.

The following extensions, not currently defined by the draft specifications, are supported:
  * Wildcard `_typeFilter` parameters which apply to all returned results. For example, adding a parameter like `*?_security=N` means this filter should be applied to all the exported results.

## Use
To initiate a bulk export job, send a `GET` request similar to the following:

``` 
GET http://localhost:4000/fhir/$export?_type=MedicationRequest
```
Note that the `Accept` header must be set to `application/fhir+json`.

Follow the URL from the `location` header of the response to this request for the results:

```
GET http://localhost:4000/bulk_jobs/a6a75d38
```
If the job is still in progress this will return a `202` response with the `x-progress` header set to `in_progress`. If the job is completed, the server will send a `200` response with a body similar to the following:

```
{
    "error": [
        {
            "error": "error fetching http://hapi.fhir.org/R/MedicationRequest",
            "query": "http://hapi.fhir.org/R/MedicationRequest"
        }
    ],
    "output": [
        {
            "count": 122,
            "query": "http://hapi.fhir.org/baseR4/MedicationRequest",
            "source": "http://hapi.fhir.org/baseR4",
            "type": "MedicationRequest",
            "url": "/files/a6a75d38/f081cfba"
        }
    ],
    "request": "/fhir/$export?_type=MedicationRequest",
    "requiresAccessToken": false,
    "self": "/bulk_jobs/a6a75d38",
    "transactionTime": "2019-04-19T20:03:21"
}
```

To download the results, follow the links included in the `url` property of each object in the `output` array.

## Configuration
The following configurations are required for the server:

  * `fhir_backends`: The list of FHIR servers from which data will be fetched. Export queries will be dispatched to all of the servers in this list. When deployed in production, this should be set as a comma-separated list in the environment variable `FHIR_BACKENDS`.
  * `exportable_fhir_resources`: This puts a hard-coded restriction on the type of resources that can be exported using this service. Any request resource type not in this set will be ignored. When deployed in production, this should be set as a comma-separated list in the environment variable `EXPORTABLE_FHIR_RESOURCES`.

## Setup

To start a development server:

  * Install dependencies with `mix deps.get`
  * Configure the database parameters in `config/dev.exs`
  * Configure the other required parameters as discussed above.
  * Create and migrate your database with `mix ecto.setup`
  * Install `node.js` dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

The server will be started at [`localhost:4000`](http://localhost:4000). For deploying in production [check out Phoenix deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Test Server
There is a `heroku`-based test server [here](https://hotaru-swarm.herokuapp.com/) in which the `master` branch is deployed. This server is backed by the [University Health Network FHIR Server]( http://hapi.fhir.org/baseR4) which is based on the R4 specifications and a [HAPI FHIR](http://hapifhir.io/) implementation.

Please note that the backend database will be reset periodically and any data stored on this test sever may be lost. Also note that `heroku` is [not an ideal platform for deploying Elixir applications](https://hexdocs.pm/phoenix/heroku.html#limitations), so this server is only for test and demo purposes.

## License
[GNU Lesser General Public License v3.0](https://github.com/mojitoholic/hotaru-swarm/blob/master/LICENSE)
