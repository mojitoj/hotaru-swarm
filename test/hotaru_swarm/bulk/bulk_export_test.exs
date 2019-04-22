defmodule HotaruSwarm.Bulk.BulkExportTest do
    alias HotaruSwarm.Bulk.BulkExport
    
    use ExUnit.Case

    test "proper parsing of paths with wildcard filters" do
        expected_result = ["http://hapi.fhir.org/baseR4/MedicationRequest?status=active&_security=N&_security=R",
            "http://hapi.fhir.org/baseR4/Patient?_security=N&_security=R",
            "http://hapi.fhir.org/R/MedicationRequest?status=active&_security=N&_security=R",
            "http://hapi.fhir.org/R/Patient?_security=N&_security=R"]

        assert BulkExport.query_urls("Patient,MedicationRequest", "MedicationRequest?status=active,*?_security=N,Consent?status=active,*?_security=R", nil) === expected_result
    end

    test "proper parsing of paths without wildcard filters" do
        expected_result = ["http://hapi.fhir.org/baseR4/MedicationRequest?status=active",
            "http://hapi.fhir.org/baseR4/Patient",
            "http://hapi.fhir.org/R/MedicationRequest?status=active",
            "http://hapi.fhir.org/R/Patient"]

        assert  BulkExport.query_urls("Patient,MedicationRequest", "MedicationRequest?status=active,Consent?status=active", nil) === expected_result
    end

    test "proper parsing of paths with since" do
        expected_result = ["http://hapi.fhir.org/baseR4/Patient?_lastUpdated=gt2019-04-23",
        "http://hapi.fhir.org/baseR4/MedicationRequest?_lastUpdated=gt2019-04-23",
        "http://hapi.fhir.org/R/Patient?_lastUpdated=gt2019-04-23",
        "http://hapi.fhir.org/R/MedicationRequest?_lastUpdated=gt2019-04-23"]

        assert  BulkExport.query_urls("Patient,MedicationRequest", nil, "2019-04-23") === expected_result
    end

    test "proper parsing of paths with both since and other wildcard" do
        expected_result = ["http://hapi.fhir.org/baseR4/Patient?_security=N&_lastUpdated=gt2019-04-23",
        "http://hapi.fhir.org/baseR4/MedicationRequest?_security=N&_lastUpdated=gt2019-04-23",
        "http://hapi.fhir.org/R/Patient?_security=N&_lastUpdated=gt2019-04-23",
        "http://hapi.fhir.org/R/MedicationRequest?_security=N&_lastUpdated=gt2019-04-23"]

        assert  BulkExport.query_urls("Patient,MedicationRequest", "*?_security=N", "2019-04-23") === expected_result
    end
end
