*** Settings ***
Documentation   Covers:
...             - https://github.com/ehrbase/openEHR_SDK/blob/develop/client/src/test/java/org/ehrbase/openehr/sdk/client/openehrclient/defaultrestclient/systematic/compositionquery/NumericTestsIT.java#L76
...             \n*Test testNumeric1()*
...             - *Cases 1-3* are passing
...             - *Cases 6-7* returning {"error":"Bad Request","message":"Not implemented: WHERE: EXISTS operator is not supported"}
...             - *Cases 4-5,8-19* returning {"error":"Bad Request","message":"Could not parse AQL query: Parse exception...}
...             \n*Cases 4-19* are skipped due to above errors. Make sure to provide expected test data & remove not-ready tag when all passed.
Resource        ../../../_resources/keywords/aql_keywords.robot
Library     DataDriver
...     file=${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/aql/fields_and_results/external/numeric/combinations/numeric_count.csv
...     dialect=excel

Suite Setup     Precondition
Suite Teardown  Admin Delete EHR For AQL


*** Variables ***
${EXPECTED_JSON_RESULTS}    ${EXPECTED_JSON_DATA_SETS}/external/numeric


*** Test Cases ***
${query_nr} SELECT ${path} FROM EHR e CONTAINS COMPOSITION c CONTAINS EVALUATION eval[openEHR-EHR-EVALUATION.minimal.v1] WHERE ${where}
    [Tags]      not-ready
    [Template]      Execute Query
    ${query_nr}     ${path}     ${where}    ${expected_file}    ${nr_of_results}


*** Keywords ***
Precondition
    Upload OPT For AQL      external/minimal_evaluation.opt
    Set Suite Variable      ${template_id}      minimal_evaluation.en.v1
    Create EHR For AQL With Custom EHR Status       file_name=status1.json
    Commit Composition For AQL      external/minimal_evaluation.json
    Set Suite Variable      ${c_uid}        ${composition_short_uid}

Execute Query
    [Arguments]     ${query_nr}     ${path}     ${where}    ${expected_file}    ${nr_of_results}
    ${actual_file}      Set Variable    ${EXPECTED_JSON_RESULTS}/${expected_file}
    ${tmp_file}         Set Variable    ${EXPECTED_JSON_RESULTS}/expected_numeric_count_tmp.json
    ${query_dict}   Create Dictionary
    ...     tmp_query=SELECT ${path} FROM EHR e CONTAINS COMPOSITION c CONTAINS EVALUATION eval[openEHR-EHR-EVALUATION.minimal.v1] WHERE ${where}
    ${query}    Set Variable    ${query_dict["tmp_query"]}
    Set AQL And Execute Ad Hoc Query    ${query}
    ${expected_res_tmp}      Set Variable       ${actual_file}
    ${file_without_replaced_vars}   Get File    ${expected_res_tmp}
    ${data_replaced_vars}    Replace Variables  ${file_without_replaced_vars}
    Create File     ${tmp_file}     ${data_replaced_vars}
    Length Should Be    ${resp_body['rows']}     ${nr_of_results}
    ${exclude_paths}	Create List    root['meta']
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${tmp_file}
    ...     exclude_paths=${exclude_paths}
    ...     ignore_order=${TRUE}    ignore_string_case=${TRUE}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!
    [Teardown]      Remove File     ${tmp_file}