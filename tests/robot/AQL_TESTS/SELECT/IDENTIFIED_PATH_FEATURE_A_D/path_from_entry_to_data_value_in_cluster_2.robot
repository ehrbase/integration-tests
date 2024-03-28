*** Settings ***
Documentation   CHECK Identified Path: Path from Entry to Data value in Cluster (using Second AQL)
...             - Covers the following:
...             - https://github.com/ehrbase/AQL_Test_CASES/blob/main/SELECT_TEST_SUIT.md#multi-selects:~:text=SELECT%20c/%7Bpath%7D%20FROM%20OBSERVATION%20o%20%5BopenEHR%2DEHR%2DOBSERVATION.conformance_observation.v0%5D%20contains%20Cluster%20c%20%5BopenEHR%2DEHR%2DCLUSTER.conformance_cluster.v0%5D

Resource        ../../../_resources/keywords/aql_keywords.robot
Library     DataDriver
...     file=${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/aql/fields_and_results/select/combinations/path_from_entry_to_data_value_in_cluster_second_query.csv
...     dialect=excel

#Suite Setup  Skip    enable Setup 'Precondition' if AQL checks are passing !!!
#Suite Teardown  Skip    enable Teardown 'Admin Delete EHR For AQL' if AQL checks are passing !!!
Suite Setup     Precondition        #enable this keyword if AQL checks are passing !!!
Suite Teardown  Admin Delete EHR For AQL    ${ehr_id}


*** Test Cases ***
SELECT c/${path} FROM OBSERVATION o[openEHR-EHR-OBSERVATION.conformance_observation.v0] CONTAINS CLUSTER c[openEHR-EHR-CLUSTER.conformance_cluster.v0]
    #[Tags]      not-ready
    [Template]      Execute Query
    ${path}    ${expected_file}    ${nr_of_results}


*** Keywords ***
Precondition
    Set Library Search Order For Tests
    Upload OPT For AQL      conformance_ehrbase.de.v0.opt
    Create EHR For AQL
    Commit Composition For AQL      conformance_ehrbase.de.v0_max_v3.json
    Set Suite Variable      ${c_uid1}      ${composition_short_uid}

Execute Query
    [Arguments]     ${path}     ${expected_file}    ${nr_of_results}
    ${query_dict}   Create Dictionary
    ...     tmp_query=SELECT c/${path} FROM OBSERVATION o[openEHR-EHR-OBSERVATION.conformance_observation.v0] CONTAINS CLUSTER c[openEHR-EHR-CLUSTER.conformance_cluster.v0]
    Log     ${query_dict["tmp_query"]}
    ${query}    Set Variable    ${query_dict["tmp_query"]}
    Log     ${query}
    Set AQL And Execute Ad Hoc Query    ${query}
    ${expected_res_tmp}      Set Variable       ${EXPECTED_JSON_DATA_SETS}/select/${expected_file}
    ${file_without_replaced_vars}   Get File    ${expected_res_tmp}
    ${data_replaced_vars}    Replace Variables  ${file_without_replaced_vars}
    Log     Expected data: ${data_replaced_vars}
    Create File     ${EXPECTED_JSON_DATA_SETS}/select/path_from_entry_to_data_value_cluster_second_query_tmp.json
    ...     ${data_replaced_vars}
    Length Should Be    ${resp_body['rows']}     ${nr_of_results}
    ${exclude_paths}	Create List    root['meta']
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${EXPECTED_JSON_DATA_SETS}/select/path_from_entry_to_data_value_cluster_second_query_tmp.json
    ...     exclude_paths=${exclude_paths}
    ...     ignore_order=${TRUE}    ignore_string_case=${TRUE}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!
    [Teardown]      Remove File     ${EXPECTED_JSON_DATA_SETS}/select/path_from_entry_to_data_value_cluster_second_query_tmp.json