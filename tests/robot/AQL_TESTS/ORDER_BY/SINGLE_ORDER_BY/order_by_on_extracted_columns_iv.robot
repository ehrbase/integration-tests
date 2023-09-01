*** Settings ***
Documentation   ORDER BY - SINGLE ORDER BY - ORDER BY ON EXTRACTED COLUMNS IV
...             - Covers: https://github.com/ehrbase/AQL_Test_CASES/blob/main/ORDER_BY_SUIT.md#order-by-on-extracted-columns-iv

Resource        ../../../_resources/keywords/aql_keywords.robot
Library     DataDriver
...     file=${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/aql/fields_and_results/order_by/combinations/order_by_extracted_columns_iv.csv
...     dialect=excel

#Suite Setup  Skip    enable Setup 'Precondition' if AQL checks are passing !!!
#Suite Teardown  Skip    enable Teardown 'Admin Delete EHR For AQL' if AQL checks are passing !!!
Suite Setup     Precondition        #enable this keyword if AQL checks are passing !!!
Suite Teardown  Run Keywords
...     Admin Delete EHR For AQL    ${ehr_id1}      AND
...     Admin Delete EHR For AQL    ${ehr_id2}


*** Test Cases ***
SELECT ${path} FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o ORDER BY ${path} ${order}
    #[Tags]      not-ready
    [Template]      Execute Query
    ${path}     ${order}    ${expected_file}    ${nr_of_results}


*** Keywords ***
Precondition
    Upload OPT For AQL      aql-conformance-ehrbase.org.v0.opt
    Upload OPT For AQL      type_repetition_conformance_ehrbase.org.opt
    Create EHR For AQL
    Set Suite Variable      ${ehr_id1}     ${ehr_id}
    Commit Composition For AQL      aql-conformance-ehrbase.org.v0_contains.json
    Set Suite Variable      ${c_uid1}      ${composition_short_uid}
    Create EHR For AQL
    Set Suite Variable      ${ehr_id2}     ${ehr_id}
    Set Suite Variable      ${ehr_id}      ${ehr_id2}
    Commit Composition For AQL      type_repetition_conformance_ehrbase.org_one_reptation.json
    Set Suite Variable      ${c_uid2}      ${composition_short_uid}

Execute Query
    [Arguments]     ${path}     ${order}    ${expected_file}    ${nr_of_results}
    ${temp_query}    Set Variable
    ...     SELECT ${path} FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o ORDER BY ${path} ${order}
    ${query}    Replace Variables       ${temp_query}
    Log     ${query}
    Set AQL And Execute Ad Hoc Query    ${query}
    ${expected_res_tmp}      Set Variable       ${EXPECTED_JSON_DATA_SETS}/order_by/${expected_file}
    ${file_without_replaced_vars}   Get File    ${expected_res_tmp}
    ${data_replaced_vars}    Replace Variables  ${file_without_replaced_vars}
    Log     Expected data: ${data_replaced_vars}
    Create File     ${EXPECTED_JSON_DATA_SETS}/order_by/order_by_with_extracted_column_iv_tmp.json
    ...     ${data_replaced_vars}
    Length Should Be    ${resp_body['rows']}     ${nr_of_results}
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${EXPECTED_JSON_DATA_SETS}/order_by/order_by_with_extracted_column_iv_tmp.json
    ...     ignore_order=${FALSE}    ignore_string_case=${TRUE}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!
    [Teardown]      Remove File     ${EXPECTED_JSON_DATA_SETS}/order_by/order_by_with_extracted_column_iv_tmp.json