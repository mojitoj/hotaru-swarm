defmodule HotaruSwarm.Bulk.BulkExportTest do
    alias HotaruSwarm.Bulk.BulkExport
    
    use ExUnit.Case

    test "proper parsing of paths with wildcard filters" do
        expected_result = ["http://hapi.fhir.org/baseR4/MedicationRequest?status=active&_security=N&_security=R",
            "http://hapi.fhir.org/baseR4/Patient?_security=N&_security=R",
            "http://hapi.fhir.org/R/MedicationRequest?status=active&_security=N&_security=R",
            "http://hapi.fhir.org/R/Patient?_security=N&_security=R"]

        assert BulkExport.query_urls("Patient,MedicationRequest", "MedicationRequest?status=active,*?_security=N,Consent?status=active,*?_security=R", "") === expected_result
    end

    test "proper parsing of paths without" do
        expected_result = ["http://hapi.fhir.org/baseR4/MedicationRequest?status=active",
            "http://hapi.fhir.org/baseR4/Patient",
            "http://hapi.fhir.org/R/MedicationRequest?status=active",
            "http://hapi.fhir.org/R/Patient"]

        assert  BulkExport.query_urls("Patient,MedicationRequest", "MedicationRequest?status=active,Consent?status=active", "") === expected_result
    end
end
