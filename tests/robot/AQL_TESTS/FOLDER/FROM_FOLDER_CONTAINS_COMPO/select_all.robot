*** Settings ***
Documentation   CHECK FOLDER CONTAINS COMPOSITION - Select All
...         - Covers: https://github.com/ehrbase/conformance-testing-documentation/blob/main/FOLDER.md#select-all
...         - *Precondition:*
...         - 1. Upload OPT; 2. Create EHR;
...         3. Create 4 compositions with conformance_ehrbase.de.v0_max.json and store their compo_ids;
...         - 4. Create Directory with folder_with_compositions.json;
...         - Send AQL query and compare response body with expected file content.
...         - *Postcondition:* Delete EHR using ADMIN endpoint.
Resource        ../../../_resources/keywords/aql_keywords.robot

Suite Setup     Precondition
Suite Teardown  Admin Delete EHR For AQL


*** Test Cases ***
Folder Contains Composition: SELECT c/uid/value, f/name/value FROM FOLDER f CONTAINS COMPOSITION c
    [Tags]      not-ready
    ${query}    Set Variable
    ...     SELECT c/uid/value, f/name/value FROM FOLDER f CONTAINS COMPOSITION c
    ${temporary_file}     Set Variable  ${EXPECTED_JSON_DATA_SETS}/folder/expected_folder_contains_compo_select_all_tmp.json
    Set AQL And Execute Ad Hoc Query    ${query}
    Length Should Be    ${resp_body['rows']}     12
    ${expected_file}      Set Variable  expected_folder_contains_compo_select_all.json
    ${expected_res_tmp}      Set Variable       ${EXPECTED_JSON_DATA_SETS}/folder/${expected_file}
    ${file_without_replaced_vars}   Get File    ${expected_res_tmp}
    ${data_replaced_vars}    Replace Variables  ${file_without_replaced_vars}
    Create File     ${temporary_file}
    ...     ${data_replaced_vars}
    ${exclude_paths}    Create List    root['meta']     root['q']
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${temporary_file}      exclude_paths=${exclude_paths}
    ...     ignore_order=${TRUE}
    ...		ignore_string_case=${TRUE}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!
    [Teardown]      Remove File     ${temporary_file}


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
