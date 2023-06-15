*** Settings ***
Documentation   CHECK SELECT PATHS WITHIN SAME HIERARCHY LEVEL 1
...             - Covers: https://github.com/ehrbase/AQL_Test_CASES/blob/main/SELECT_TEST_SUIT.md#paths-within-same-hierarchy-level-i
Resource        ../../../_resources/keywords/aql_keywords.robot


*** Test Cases ***
Test Paths Within Same Hierarchy Lvl 1: SELECT p/time/value FROM POINT_EVENT p
    [Documentation]     - *Precondition:* 1. Create OPT; 2. Create EHR; 3. Create Composition
    ...         - Send AQL 'SELECT p/time/value FROM POINT_EVENT p'
    ...         - Check that result contains 4 rows
    ...         - Check if actual response == expected response
    ...         - *Postcondition:* Delete EHR using ADMIN endpoint. This is deleting compositions linked to EHR.
    #[Tags]      not-ready
    [Setup]     Precondition
    ${query}    Set Variable    SELECT p/time/value FROM POINT_EVENT p
    Set AQL And Execute Ad Hoc Query        ${query}
    ${expected_result}      Set Variable    ${EXPECTED_JSON_DATA_SETS}/select/paths_same_hierarchy_lvl1.json
    Log     Add test data once 200 is returned. File: ${expected_result}    console=yes
    ${exclude_paths}    Create List    root['rows'][0][0]['uid']
    Length Should Be    ${resp_body['rows']}     4
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${expected_result}      exclude_paths=${exclude_paths}
    #Log To Console    \n\n${diff}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!
    [Teardown]      Admin Delete EHR For AQL


*** Keywords ***
Precondition
    Upload OPT For AQL      aql-conformance-ehrbase.org.v0.opt
    Create EHR For AQL
    Commit Composition For AQL      aql-conformance-ehrbase.org.v0_contains.json