*** Settings ***
Documentation   ORDER BY - SINGLE ORDER BY - ORDER BY PATHS WITHIN SAME HIERARCHY LEVEL II
...             - Covers: https://github.com/ehrbase/conformance-testing-documentation/blob/main/ORDER_BY_SUIT.md#order-by-paths-within-same-hierarchy-level-ii

Resource        ../../../_resources/keywords/aql_keywords.robot
Library     DataDriver
...     file=${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/aql/fields_and_results/order_by/combinations/order_by_paths_within_same_hierarchy_lvl_ii.csv
...     dialect=excel

#Suite Setup  Skip    enable Setup 'Precondition' if AQL checks are passing !!!
#Suite Teardown  Skip    enable Teardown 'Admin Delete EHR For AQL' if AQL checks are passing !!!
Suite Setup     Precondition        #enable this keyword if AQL checks are passing !!!
Suite Teardown  Admin Delete EHR For AQL    ${ehr_id}


*** Test Cases ***
SELECT ${path} FROM EHR e CONTAINS COMPOSITION c CONTAINS EVENT_CONTEXT ec ORDER BY ${path} ${order}
    #[Tags]      not-ready
    [Template]      Execute Query
    ${path}     ${order}    ${expected_file}    ${nr_of_results}


*** Keywords ***
Precondition
    Set Library Search Order For Tests
    Upload OPT For AQL      conformance_ehrbase.de.v0.opt
    Create EHR For AQL
    Commit Composition For AQL      conformance_ehrbase.de.v0_known_date_type_1.json
    Set Suite Variable      ${c_uid1}      ${composition_short_uid}
    Commit Composition For AQL      conformance_ehrbase.de.v0_known_date_type_2.json
    Set Suite Variable      ${c_uid2}      ${composition_short_uid}

Execute Query
    [Arguments]     ${path}     ${order}    ${expected_file}    ${nr_of_results}
    #${temp_query}    Set Variable
    #...     SELECT ${path} FROM EHR e CONTAINS COMPOSITION c CONTAINS EVENT_CONTEXT ec ORDER BY ${path} ${order}
    #${query}    Replace Variables       ${temp_query}
    ${query_dict}   Create Dictionary   tmp_query=SELECT ${path} FROM EHR e CONTAINS COMPOSITION c CONTAINS EVENT_CONTEXT ec ORDER BY ${path} ${order}
    Log     ${query_dict["tmp_query"]}
    ${query}    Set Variable    ${query_dict["tmp_query"]}
    Log     ${query}
    Set AQL And Execute Ad Hoc Query    ${query}
    ${expected_res_tmp}      Set Variable       ${EXPECTED_JSON_DATA_SETS}/order_by/${expected_file}
    ${file_without_replaced_vars}   Get File    ${expected_res_tmp}
    ${data_replaced_vars}    Replace Variables  ${file_without_replaced_vars}
    Log     Expected data: ${data_replaced_vars}
    Create File     ${EXPECTED_JSON_DATA_SETS}/order_by/order_by_paths_same_hierarchy_lvl_ii_tmp.json
    ...     ${data_replaced_vars}
    Length Should Be    ${resp_body['rows']}     ${nr_of_results}
    ${exclude_paths}	Create List    root['meta']
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${EXPECTED_JSON_DATA_SETS}/order_by/order_by_paths_same_hierarchy_lvl_ii_tmp.json
    ...     exclude_paths=${exclude_paths}
    ...     ignore_order=${FALSE}    ignore_string_case=${TRUE}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!
    [Teardown]      Remove File     ${EXPECTED_JSON_DATA_SETS}/order_by/order_by_paths_same_hierarchy_lvl_ii_tmp.json