*** Settings ***
Documentation   ORDER BY - SINGLE ORDER BY - ORDER BY PATH FROM ENTRY TO DV_ORDERED
...             - Covers: https://github.com/ehrbase/conformance-testing-documentation/blob/main/ORDER_BY_SUIT.md#order-by-path-from-entry-to-dvordered

Resource        ../../../_resources/keywords/aql_keywords.robot
Library     DataDriver
...     file=${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/aql/fields_and_results/order_by/combinations/order_by_path_from_entry_to_dv_ordered.csv
...     dialect=excel

#Suite Setup  Skip    enable Setup 'Precondition' if AQL checks are passing !!!
#Suite Teardown  Skip    enable Teardown 'Admin Delete EHR For AQL' if AQL checks are passing !!!
Suite Setup     Precondition        #enable this keyword if AQL checks are passing !!!
Suite Teardown  Admin Delete EHR For AQL    ${ehr_id}


*** Test Cases ***
SELECT ${path}${spath} FROM OBSERVATION o[openEHR-EHR-OBSERVATION.conformance_observation.v0] ORDER BY ${path} ${order}
    #[Tags]      not-ready
    [Template]      Execute Query
    ${path}     ${spath}    ${order}    ${expected_file}    ${nr_of_results}


*** Keywords ***
Precondition
    Set Library Search Order For Tests
    Upload OPT For AQL      conformance_ehrbase.de.v0.opt
    Create EHR For AQL
    Commit Composition For AQL      conformance_ehrbase.de.v0_max_v2.json
    Set Suite Variable      ${c_uid1}      ${composition_short_uid}

Execute Query
    [Arguments]     ${path}     ${spath}    ${order}    ${expected_file}    ${nr_of_results}
    ${query_dict}   Create Dictionary
    ...     tmp_query=SELECT ${path}${spath} FROM OBSERVATION o[openEHR-EHR-OBSERVATION.conformance_observation.v0] ORDER BY ${path} ${order}
    Log     ${query_dict["tmp_query"]}
    ${query}    Set Variable    ${query_dict["tmp_query"]}
    Log     ${query}
    Set AQL And Execute Ad Hoc Query    ${query}
    ${expected_result_file}      Set Variable       ${EXPECTED_JSON_DATA_SETS}/order_by/${expected_file}
    Length Should Be    ${resp_body['rows']}     ${nr_of_results}
    ${exclude_paths}	Create List    root['meta']
    Set Test Variable   ${path}     ${path}
    Set Test Variable   ${spath}    ${spath}
    Set Test Variable   ${order}    ${order}
    ${expected_json}    Get File And Replace Dynamic Vars In File And Store As String
    ...     test_data_file=${expected_result_file}
    #Log     Expected data: ${data_replaced_vars}
    ${diff}     compare json-strings
    ...     ${resp_body_actual}     ${expected_json}
    ...     exclude_paths=${exclude_paths}
    ...     ignore_order=${FALSE}    ignore_string_case=${TRUE}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!