*** Settings ***
Documentation   Drill down along paths: Drill down EHR
...             - Covers the following:
...             - https://github.com/ehrbase/AQL_Test_CASES/blob/main/SELECT_TEST_SUIT.md#drill-down-ehr

Resource        ../../../_resources/keywords/aql_keywords.robot
Resource        ../../../_resources/keywords/ehr_keywords.robot
Library     DataDriver
...     file=${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/aql/fields_and_results/select/combinations/drill_down_ehr.csv
...     dialect=excel

Suite Setup     Precondition
Suite Teardown  Admin Delete EHR For AQL    ${ehr_id}


*** Test Cases ***
${query_nr} SELECT ${path} FROM EHR e
    [Template]      Execute Query
    ${path}    ${expected_file}    ${nr_of_results}



*** Keywords ***
Precondition
    generate random ehr_id
    Create EHR For AQL      ehr_id=${ehr_id}
    Set Suite Variable      ${ehr_status_uid}       ${response['body']['ehr_status']['uid']['value']}
    Set Suite Variable      ${ehr_status_subject_id}
    ...     ${response['body']['ehr_status']['subject']['external_ref']['id']['value']}
    Set Suite Variable      ${ehr_status_subject_namespace}
    ...     ${response['body']['ehr_status']['subject']['external_ref']['namespace']}
    Set Suite Variable      ${ehr_time_created}     ${response['body']['time_created']['value']}

Execute Query
    [Arguments]     ${path}     ${expected_file}    ${nr_of_results}
    ${temp_file}    Set Variable
    ...     ${EXPECTED_JSON_DATA_SETS}/version/expected_drill_down_ehr_tmp.json
    ${expected_res_tmp}     Set Variable
    ...     ${EXPECTED_JSON_DATA_SETS}/select/${expected_file}
    ${query_dict}   Create Dictionary
    ...     tmp_query=SELECT ${path} FROM EHR e
    ${query}    Set Variable    ${query_dict["tmp_query"]}
    Log     ${query}
    Set AQL And Execute Ad Hoc Query    ${query}
    ${file_without_replaced_vars}   Get File    ${expected_res_tmp}
    ${data_replaced_vars}    Replace Variables  ${file_without_replaced_vars}
    Log     Expected data: ${data_replaced_vars}
    Create File     ${temp_file}    ${data_replaced_vars}
    Length Should Be    ${resp_body['rows']}     ${nr_of_results}
    ${exclude_paths}	Create List    root['meta']     root['q']
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${temp_file}
    ...     exclude_paths=${exclude_paths}
    ...     ignore_order=${TRUE}    ignore_string_case=${TRUE}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!
    [Teardown]      Remove File     ${temp_file}