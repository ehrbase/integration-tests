*** Settings ***
Documentation   CHECK FOLDER CONTAINS COMPOSITION - Select by name
...         - Covers: https://github.com/ehrbase/conformance-testing-documentation/blob/main/FOLDER.md#select-by-name
...         - *Precondition:*
...         - 1. Upload OPT; 2. Create EHR;
...         3. Create 4 compositions with conformance_ehrbase.de.v0_max.json and store their compo_ids;
...         - 4. Create Directory with folder_with_compositions.json;
...         - Send AQL query and compare response body with expected file content.
...         - *Postcondition:* Delete EHR using ADMIN endpoint.
Resource        ../../../_resources/keywords/aql_keywords.robot
Library     DataDriver
...     file=${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/aql/fields_and_results/folder/combinations/folder_contains_compo_select_by_name.csv
...     dialect=excel

Suite Setup     Precondition
Suite Teardown  Admin Delete EHR For AQL


*** Test Cases ***
${query_nr} SELECT c/uid/value FROM FOLDER f CONTAINS COMPOSITION c WHERE f/name/value = '${name}'
    [Tags]      not-ready
    [Template]      Execute Query
    ${name}    ${expected_file}    ${nr_of_results}



*** Keywords ***
Precondition
    Set Library Search Order For Tests
    Upload OPT For AQL      conformance_ehrbase.de.v0.opt
    Create EHR For AQL
    Commit Composition For AQL      conformance_ehrbase.de.v0_max.json
    Set Suite Variable      ${c_uid1}   ${composition_short_uid}
    Commit Composition For AQL      conformance_ehrbase.de.v0_max.json
    Set Suite Variable      ${c_uid2}   ${composition_short_uid}
    Commit Composition For AQL      conformance_ehrbase.de.v0_max.json
    Set Suite Variable      ${c_uid3}   ${composition_short_uid}
    Commit Composition For AQL      conformance_ehrbase.de.v0_max.json
    Set Suite Variable      ${c_uid4}   ${composition_short_uid}
    Create Directory For AQL    folder_with_compositions.json   has_robot_vars=${TRUE}

Execute Query
    [Arguments]     ${name}     ${expected_file}    ${nr_of_results}
    ${query}    Set Variable    SELECT c/uid/value FROM FOLDER f CONTAINS COMPOSITION c WHERE f/name/value = '${name}'
    ${expected_file_with_replaced_vars}     Set Variable
    ...     ${EXPECTED_JSON_DATA_SETS}/folder/expected_folder_contains_compo_select_by_name_tmp.json
    Set AQL And Execute Ad Hoc Query    ${query}
    ${expected_res_tmp}     Set Variable    ${EXPECTED_JSON_DATA_SETS}/folder/${expected_file}
    ${file_without_replaced_vars}   Get Binary File    ${expected_res_tmp}
    ${data_replaced_vars}   Replace Variables  ${file_without_replaced_vars}
    Create Binary File      ${expected_file_with_replaced_vars}
    ...     ${data_replaced_vars}
    Length Should Be    ${resp_body['rows']}     ${nr_of_results}
    ${exclude_paths}	Create List    root['meta']
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${expected_file_with_replaced_vars}
    ...     exclude_paths=${exclude_paths}
    ...     ignore_order=${TRUE}    ignore_string_case=${TRUE}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!
    [Teardown]      Remove File     ${expected_file_with_replaced_vars}