*** Settings ***
Documentation   WHERE - COMPARE WITH EXTRACTED COLUMN II
...             - Covers: https://github.com/ehrbase/AQL_Test_CASES/blob/main/WHERE_TEST_SUIT.md#compare-with-extracted-column-ii--httpsvitagroup-agatlassiannetwikispacespenpages38216361architecture-aqlfeaturelistwhere
...         - *Precondition:* 1. Create OPT; 2. Create EHR; 3. Create Composition
...         - Send AQL 'SELECT o/uid/value FROM COMPOSITION CONTAINS OBSERVATION o WHERE {where}'
...         - {where} can be:
...         - o/uid/value = '94c0e756-e892-4985-884b-46829605a236',
...         - o/archetype_node_id = 'openEHR-EHR-OBSERVATION.conformance_observation.v0',
...         - o/name/value = 'Blood pressure'
...         Check if actual response == expected response
...         - *Postcondition:* Delete EHR using ADMIN endpoint. This is deleting compositions linked to EHR.
Resource        ../../../_resources/keywords/aql_keywords.robot
Library     DataDriver
...     file=${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/aql/fields_and_results/where/combinations/compare_extracted_column_ii.csv
...     dialect=excel

#Suite Setup  Skip    enable Setup 'Precondition' if AQL checks are passing !!!
#Suite Teardown  Skip    enable Teardown 'Admin Delete EHR For AQL' if AQL checks are passing !!!
Suite Setup     Precondition        #enable this keyword if AQL checks are passing !!!
Suite Teardown  Admin Delete EHR For AQL


*** Test Cases ***
Test Compare With Extracted Column II: SELECT o/uid/value FROM COMPOSITION CONTAINS OBSERVATION o WHERE ${where}
    #[Tags]      not-ready
    [Template]      Execute Query
    ${where}    ${expected_file}    ${nr_of_results}


*** Keywords ***
Precondition
    Upload OPT For AQL      aql-conformance-ehrbase.org.v0.opt
    Create EHR For AQL
    Commit Composition For AQL      aql-conformance-ehrbase.org.v0_contains.json

Execute Query
    [Arguments]     ${where}    ${expected_file}    ${nr_of_results}
    Log     Add test data to file ${expected_file} - when 200 is returned.      console=yes
    ${temp_query}    Set Variable       SELECT o/uid/value FROM COMPOSITION CONTAINS OBSERVATION o WHERE ${where}
    ${query}    Replace Variables       ${temp_query}
    Log     ${query}
    Set AQL And Execute Ad Hoc Query    ${query}
    Log     ${expected_file}
    ${expected_result}      Set Variable    ${EXPECTED_JSON_DATA_SETS}/where/${expected_file}
    Length Should Be    ${resp_body['rows']}     ${nr_of_results}
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${expected_result}
    ...     ignore_order=${TRUE}    ignore_string_case=${TRUE}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!