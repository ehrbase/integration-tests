*** Settings ***
Documentation   CHECK FROM EHR AQL RESULT
...             - Covers: https://github.com/ehrbase/AQL_Test_CASES/blob/main/FROM_TEST_SUIT.MD#test-from-ehr
Resource        ../../../_resources/keywords/aql_keywords.robot


*** Test Cases ***
Test From EHR
    [Documentation]     - *Precondition:* 1. Create OPT; 2. Create EHR; 3. Create Composition
    ...         - Send AQL 'SELECT e/ehr_id/value FROM EHR e'
    ...         - Check query from response == query from script
    ...         - Check response rows to have the same ehr_id value as it was created in Precondition
    ...         - Check length of response rows to be 1
    ...         - *Postcondition:* Delete EHR using ADMIN endpoint. This is deleting compositions linked to EHR.
    #[Tags]      not-ready
    [Setup]     Precondition
    ${query}    Set Variable    SELECT e/ehr_id/value FROM EHR e
    Set AQL And Execute Ad Hoc Query        ${query}
    Should Be Equal As Strings      ${resp_body_query}      ${query}
    Should Be Equal As Strings      ${resp_body['rows'][0][0]}      ${ehr_id}
    Should Be Equal As Strings      ${resp_body_columns[0]['path']}       e/ehr_id/value
    Should Be Equal As Strings      ${resp_body_columns[0]['name']}       \#0
    Length Should Be    ${resp_body_columns}        1
    Length Should Be    ${resp_body['rows'][0]}     1
    [Teardown]      Admin Delete EHR For AQL


*** Keywords ***
Precondition
    Upload OPT For AQL      conformance_ehrbase.de.v0.opt
    Create EHR For AQL
    Commit Composition For AQL      conformance_ehrbase.de.v0_max.json