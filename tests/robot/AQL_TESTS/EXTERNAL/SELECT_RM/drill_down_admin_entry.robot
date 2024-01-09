*** Settings ***
Documentation   Covers:
...             - https://github.com/ehrbase/openEHR_SDK/blob/develop/client/src/test/java/org/ehrbase/openehr/sdk/client/openehrclient/defaultrestclient/systematic/compositionquery/SelectRMIT.java#L176
...             \n*Test testAdminEntryDrillDown()*
Resource        ../../../_resources/keywords/aql_keywords.robot
Library     DataDriver
...     file=${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/aql/fields_and_results/external/select_rm/combinations/drill_down_admin_entry.csv
...     dialect=excel

Suite Setup     Precondition
Suite Teardown  Admin Delete EHR For AQL


*** Variables ***
${EXPECTED_JSON_RESULTS}    ${EXPECTED_JSON_DATA_SETS}/external/select_rm


*** Test Cases ***
${query_nr} SELECT ${path} FROM EHR e[ehr_id/value = '${ehr_id}'] CONTAINS COMPOSITION c[openEHR-EHR-COMPOSITION.test_all_types.v1] CONTAINS SECTION s[openEHR-EHR-SECTION.test_all_types.v1] CONTAINS ADMIN_ENTRY a[openEHR-EHR-ADMIN_ENTRY.test_all_types.v1] WHERE c/uid/value = '${c_uid}'
    [Template]      Execute Query
    ${query_nr}     ${path}     ${expected_file}    ${nr_of_results}


*** Keywords ***
Precondition
    Upload OPT For AQL      external/test_all_types.opt
    Set Suite Variable      ${template_id}      test_all_types.en.v1
    Create EHR For AQL With Custom EHR Status       file_name=status1.json
    Commit Composition For AQL      external/all_types_systematic_tests.json
    Set Suite Variable      ${c_uid}        ${composition_short_uid}

Execute Query
    [Arguments]     ${query_nr}     ${path}     ${expected_file}    ${nr_of_results}
    ${actual_file}      Set Variable    ${EXPECTED_JSON_RESULTS}/${expected_file}
    ${tmp_file}         Set Variable    ${EXPECTED_JSON_RESULTS}/expected_drill_down_admin_entry_tmp.json
    ${query_dict}   Create Dictionary
    ...     tmp_query=SELECT ${path} FROM EHR e[ehr_id/value = '${ehr_id}'] CONTAINS COMPOSITION c[openEHR-EHR-COMPOSITION.test_all_types.v1] CONTAINS SECTION s[openEHR-EHR-SECTION.test_all_types.v1] CONTAINS ADMIN_ENTRY a[openEHR-EHR-ADMIN_ENTRY.test_all_types.v1] WHERE c/uid/value = '${c_uid}'
    ${query}    Set Variable    ${query_dict["tmp_query"]}
    Set AQL And Execute Ad Hoc Query    ${query}
    ${expected_res_tmp}      Set Variable       ${actual_file}
    ${file_without_replaced_vars}   Get File    ${expected_res_tmp}
    ${data_replaced_vars}    Replace Variables  ${file_without_replaced_vars}
    Create File     ${tmp_file}     ${data_replaced_vars}
    Length Should Be    ${resp_body['rows']}     ${nr_of_results}
    ${exclude_paths}	Create List    root['meta']     root['q']
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${tmp_file}
    ...     exclude_paths=${exclude_paths}
    ...     ignore_order=${TRUE}    ignore_string_case=${TRUE}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!
    [Teardown]      Remove File     ${tmp_file}