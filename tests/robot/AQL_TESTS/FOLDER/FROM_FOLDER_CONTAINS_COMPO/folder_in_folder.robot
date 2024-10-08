*** Settings ***
Documentation   CHECK FOLDER CONTAINS COMPOSITION - Folder in Folder
...         - Covers: https://github.com/ehrbase/conformance-testing-documentation/blob/main/FOLDER.md#folder-in-folder
...         - *Precondition:*
...         - 1. Upload OPT; 2. Create EHR;
...         3. Create 4 compositions with conformance_ehrbase.de.v0_max.json and store their compo_ids;
...         - 4. Create Directory with folder_with_compositions.json;
...         - Send AQL query and compare response body with expected file content.
...         - *Postcondition:* Delete EHR using ADMIN endpoint.
Resource        ../../../_resources/keywords/aql_keywords.robot


Suite Setup     Precondition
Suite Teardown  Admin Delete EHR For AQL


*** Variables ***
${q}   SELECT c/uid/value FROM FOLDER f1[openEHR-EHR-FOLDER.episode_of_care.v1] CONTAINS FOLDER f2[openEHR-EHR-FOLDER.episode_of_care.v1] CONTAINS COMPOSITION c


*** Test Cases ***
Folder In Folder: ${q}
    Set Test Variable   ${query}    ${q}
    Set AQL And Execute Ad Hoc Query    ${query}
    ${temporary_file}     Set Variable  ${EXPECTED_JSON_DATA_SETS}/folder/expected_contains_compo_folder_in_folder_tmp.json
    Length Should Be    ${resp_body['rows']}     1
    ${expected_file}        Set Variable    expected_contains_compo_folder_in_folder.json
    ${expected_res_tmp}     Set Variable    ${EXPECTED_JSON_DATA_SETS}/folder/${expected_file}
    ${file_without_replaced_vars}   Get File    ${expected_res_tmp}
    ${data_replaced_vars}    Replace Variables  ${file_without_replaced_vars}
    Create File     ${temporary_file}
    ...     ${data_replaced_vars}
    ${exclude_paths}    Create List    root['meta']     root['q']
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${temporary_file}      exclude_paths=${exclude_paths}
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