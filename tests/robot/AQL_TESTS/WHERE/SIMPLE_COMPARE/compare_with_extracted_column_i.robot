*** Settings ***
Documentation   WHERE - COMPARE WITH EXTRACTED COLUMN I
...             - Covers: https://github.com/ehrbase/AQL_Test_CASES/blob/main/WHERE_TEST_SUIT.md#compare-with-extracted-column-i--httpsvitagroup-agatlassiannetwikispacespenpages38216361architecture-aqlfeaturelistwhere
...         - *Precondition:* 1. Create OPTs; 2. Create EHRs; 3. Create Compositions
...         - Send AQL 'SELECT e/ehr_id/value, c/uid/value FROM EHR e CONTAINS COMPOSITION c WHERE {where}'
...         - {where} can be:
...         - e/ehr_id/value = {ehr_id1},
...         - e/ehr_id/value = {ehr_id2},
...         - e/ehr_id/value != {ehr_id1},
...         - e/ehr_id/value != {ehr_id2},
...         - c/uid/value = {c_uid1},
...         - c/uid/value = {c_uid2},
...         - c/uid/value != {c_uid1},
...         - c/uid/value != {c_uid2},
...         - c/archetype_details/template_id/value = conformance-ehrbase.de.v0,
...         - c/name/value = type_repetition_conformance_ehrbase.org
...         Check if actual response == expected response
...         - *Postcondition:* Delete all EHRs using ADMIN endpoint. This is deleting compositions linked to EHRs.
Resource        ../../../_resources/keywords/aql_keywords.robot
Library     DataDriver
...     file=${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/aql/fields_and_results/where/combinations/compare_extracted_column_i.csv
...     dialect=excel

#Suite Setup  Skip    enable Setup 'Precondition' if AQL checks are passing !!!
#Suite Teardown  Skip    enable Teardown 'Admin Delete EHR For AQL' if AQL checks are passing !!!
Suite Setup     Precondition        #enable this keyword if AQL checks are passing !!!
Suite Teardown  Run Keywords    Admin Delete EHR For AQL    ${ehr_id1}      AND
...         Admin Delete EHR For AQL    ${ehr_id2}


*** Test Cases ***
Test Compare With Extracted Column I: SELECT e/ehr_id/value, c/uid/value FROM EHR e CONTAINS COMPOSITION c WHERE ${where}
    #[Tags]      not-ready
    [Template]      Execute Query
    ${where}    ${expected_file}


*** Keywords ***
Precondition
    Upload OPT For AQL      conformance_ehrbase.de.v0.opt
    Upload OPT For AQL      type_repetition_conformance_ehrbase.org.opt
    Create EHR For AQL
    Set Suite Variable       ${ehr_id1}    ${ehr_id}
    Commit Composition For AQL      conformance_ehrbase.de.v0_max.json
    Set Suite Variable       ${c_uid1}      ${composition_short_uid}
    Create EHR For AQL
    Set Suite Variable       ${ehr_id2}    ${ehr_id}
    Commit Composition For AQL      type_repetition_conformance_ehrbase.org_one_reptation.json
    Set Suite Variable       ${c_uid2}      ${composition_short_uid}

Execute Query
    [Arguments]     ${where}    ${expected_file}
    ${temp_query}    Set Variable       SELECT e/ehr_id/value, c/uid/value FROM EHR e CONTAINS COMPOSITION c WHERE ${where}
    ${query}    Replace Variables       ${temp_query}
    Log     ${query}
    Set AQL And Execute Ad Hoc Query    ${query}
    ${expected_res_tmp}      Set Variable       ${EXPECTED_JSON_DATA_SETS}/where/${expected_file}
    ${file_without_replaced_vars}   Get File    ${expected_res_tmp}
    ${data_replaced_vars}    Replace Variables  ${file_without_replaced_vars}
    Log     Expected data: ${data_replaced_vars}
    Create File     ${EXPECTED_JSON_DATA_SETS}/where/expected_ehr_compo_tmp.json
    ...     ${data_replaced_vars}
    Length Should Be    ${resp_body['rows']}     1
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${EXPECTED_JSON_DATA_SETS}/where/expected_ehr_compo_tmp.json
    ...     ignore_order=${TRUE}    ignore_string_case=${TRUE}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!
    [Teardown]      Remove File     ${EXPECTED_JSON_DATA_SETS}/where/expected_ehr_compo_tmp.json
