*** Settings ***
Documentation   WHERE - SIMPLE COMPARE - Compare by DV_DATE
...             - Covers the following:
...             - https://github.com/ehrbase/AQL_Test_CASES/blob/main/WHERE_TEST_SUIT.md#compare-by-dv_date

Resource        ../../../_resources/keywords/aql_keywords.robot
Library     DataDriver
...     file=${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/aql/fields_and_results/where/combinations/compare_by_dv_date.csv
...     dialect=excel

#Suite Setup  Skip    enable Setup 'Precondition' if AQL checks are passing !!!
#Suite Teardown  Skip    enable Teardown 'Admin Delete EHR For AQL' if AQL checks are passing !!!
Suite Setup     Precondition        #enable this keyword if AQL checks are passing !!!
Suite Teardown  Admin Delete EHR For AQL    ${ehr_id}


*** Test Cases ***
SELECT ${path}/value FROM EHR e CONTAINS COMPOSITION c CONTAINS EVENT_CONTEXT ec WHERE ${path} ${condition}
    #[Tags]      not-ready
    [Template]      Execute Query
    ${path}     ${condition}    ${expected_file}    ${nr_of_results}


*** Keywords ***
Precondition
    Upload OPT For AQL      conformance_ehrbase.de.v0.opt
    Create EHR For AQL
    Commit Composition For AQL      conformance_ehrbase.de.v0_known_date_type_1.json
    Set Suite Variable       ${c_uid1}      ${composition_short_uid}
    Commit Composition For AQL      conformance_ehrbase.de.v0_known_date_type_2.json
    Set Suite Variable       ${c_uid2}      ${composition_short_uid}
    Commit Composition For AQL      conformance_ehrbase.de.v0_known_date_type_3.json
    Set Suite Variable       ${c_uid3}      ${composition_short_uid}
    Commit Composition For AQL      conformance_ehrbase.de.v0_known_date_type_4.json
    Set Suite Variable       ${c_uid4}      ${composition_short_uid}

Execute Query
    [Arguments]     ${path}     ${condition}     ${expected_file}   ${nr_of_results}
    #Log     Add test data once 200 is returned. File: ${expected_file}    console=yes
    ${query_dict}   Create Dictionary
    ...     tmp_query=SELECT ${path}/value FROM EHR e CONTAINS COMPOSITION c CONTAINS EVENT_CONTEXT ec WHERE ${path} ${condition}
    Log     ${query_dict["tmp_query"]}
    ${query}    Set Variable    ${query_dict["tmp_query"]}
    Log     ${query}
    Set AQL And Execute Ad Hoc Query    ${query}
    ${expected_res_tmp}      Set Variable       ${EXPECTED_JSON_DATA_SETS}/where/${expected_file}
    ${file_without_replaced_vars}   Get Binary File    ${expected_res_tmp}
    ${data_replaced_vars}    Replace Variables  ${file_without_replaced_vars}
    Log     Expected data: ${data_replaced_vars}
    Create Binary File     ${EXPECTED_JSON_DATA_SETS}/where/compare_by_dv_date_tmp.json
    ...     ${data_replaced_vars}
    Length Should Be    ${resp_body['rows']}     ${nr_of_results}
    ${exclude_paths}	Create List    root['meta']
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${EXPECTED_JSON_DATA_SETS}/where/compare_by_dv_date_tmp.json
    ...     exclude_paths=${exclude_paths}
    ...     ignore_order=${TRUE}    ignore_string_case=${TRUE}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!
    [Teardown]      Remove File     ${EXPECTED_JSON_DATA_SETS}/where/compare_by_dv_date_tmp.json