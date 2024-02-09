*** Settings ***
Documentation   CHECK SELECT AS IN RESULT
...             - Covers: https://github.com/ehrbase/AQL_Test_CASES/blob/main/SELECT_TEST_SUIT.md#as-in-result
Resource        ../../../_resources/keywords/aql_keywords.robot


*** Test Cases ***
Test As In Result: SELECT c AS full FROM COMPOSITION c
    [Documentation]     - *Precondition:* 1. Create OPT; 2. Create EHR; 3. Create Composition
    ...         - Send AQL 'SELECT c AS full FROM COMPOSITION c'
    ...         - Check if actual response == expected response
    ...         - *Postcondition:* Delete EHR using ADMIN endpoint. This is deleting compositions linked to EHR.
    [Setup]     Precondition
    ${query}    Set Variable    SELECT c AS full FROM COMPOSITION c
    Set AQL And Execute Ad Hoc Query        ${query}
    ${expected_result}      Set Variable    ${EXPECTED_JSON_DATA_SETS}/select/composition_complete_return.json
    ${exclude_paths}    Create List    root['meta']     root['q']   root['rows'][0][0]['uid']
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${expected_result}      exclude_paths=${exclude_paths}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!
    [Teardown]      Admin Delete EHR For AQL

Check Composition Is Returned For Full Composition Uid
    [Documentation]     - *Precondition:* 1. Create OPT; 2. Create EHR; 3. Create Composition
    ...         - Send AQL "SELECT c AS full FROM COMPOSITION c WHERE c/uid/value='{compo_uid}'"
    ...         - Check if actual response == expected response
    ...         - *Postcondition:* Delete EHR using ADMIN endpoint. This is deleting compositions linked to EHR.
    ...         - https://vitagroup-ag.atlassian.net/browse/CDR-1291
    [Setup]     Precondition
    ${query}    Set Variable    SELECT c AS full FROM COMPOSITION c WHERE c/uid/value='${compo_id}::${CREATING_SYSTEM_ID}::1'
    Set AQL And Execute Ad Hoc Query        ${query}
    ${expected_result}      Set Variable    ${EXPECTED_JSON_DATA_SETS}/select/expected_composition_full_uid.json
    ${exclude_paths}    Create List    root['meta']     root['q']   root['rows'][0][0]['uid']
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${expected_result}      exclude_paths=${exclude_paths}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!
    [Teardown]      Admin Delete EHR For AQL

Check Composition Is Not Returned For Full Composition Uid - Non Existing Version Id
    [Documentation]     - *Precondition:* 1. Create OPT; 2. Create EHR; 3. Create Composition
    ...         - Send AQL "SELECT c AS full FROM COMPOSITION c WHERE c/uid/value='{compo_uid}'" version id not existing
    ...         - Check if actual response == expected response
    ...         - *Postcondition:* Delete EHR using ADMIN endpoint. This is deleting compositions linked to EHR.
    ...         - https://vitagroup-ag.atlassian.net/browse/CDR-1291
    [Setup]     Precondition
    ${query}    Set Variable    SELECT c AS full FROM COMPOSITION c WHERE c/uid/value='${compo_id}::${CREATING_SYSTEM_ID}::2'
    Set AQL And Execute Ad Hoc Query        ${query}
    ${expected_result}      Set Variable    ${EXPECTED_JSON_DATA_SETS}/select/expected_composition_full_uid_not_existing_version.json
    ${exclude_paths}    Create List    root['meta']     root['q']   root['rows'][0][0]['uid']
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${expected_result}      exclude_paths=${exclude_paths}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!
    [Teardown]      Admin Delete EHR For AQL

Check Composition Is Not Returned For Full Composition Uid - Non Existing System Id
    [Documentation]     - *Precondition:* 1. Create OPT; 2. Create EHR; 3. Create Composition
    ...         - Send AQL "SELECT c AS full FROM COMPOSITION c WHERE c/uid/value='{compo_uid}'" system id not existing
    ...         - Check if actual response == expected response
    ...         - *Postcondition:* Delete EHR using ADMIN endpoint. This is deleting compositions linked to EHR.
    ...         - https://vitagroup-ag.atlassian.net/browse/CDR-1291
    [Setup]     Precondition
    ${query}    Set Variable    SELECT c AS full FROM COMPOSITION c WHERE c/uid/value='${compo_id}::non-existing-system::1'
    Set AQL And Execute Ad Hoc Query        ${query}
    ${expected_result}      Set Variable    ${EXPECTED_JSON_DATA_SETS}/select/expected_composition_full_uid_not_existing_system.json
    ${exclude_paths}    Create List    root['meta']     root['q']   root['rows'][0][0]['uid']
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${expected_result}      exclude_paths=${exclude_paths}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!
    [Teardown]      Admin Delete EHR For AQL

Check Composition Is Returned For Full Composition Uid - Complex Query
    [Documentation]     - *Precondition:* 1. Create OPT; 2. Create EHR; 3. Create Composition
    ...         - Send AQL "SELECT e/ehr_id/value, c/uid/value, o/uid/value, p/time/value FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o CONTAINS POINT_EVENT p WHERE c/uid/value='{compo_uid}'"
    ...         - Check if actual response == expected response
    ...         - *Postcondition:* Delete EHR using ADMIN endpoint. This is deleting compositions linked to EHR.
    ...         - https://vitagroup-ag.atlassian.net/browse/CDR-1291
    [Setup]     Precondition
    ${query}    Set Variable    SELECT e/ehr_id/value, c/uid/value, o/uid/value, p/time/value FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o CONTAINS POINT_EVENT p WHERE c/uid/value='${compo_id}::${CREATING_SYSTEM_ID}::1'
    Set AQL And Execute Ad Hoc Query        ${query}
    ${expected_res_tmp}      Set Variable       ${EXPECTED_JSON_DATA_SETS}/select/expected_composition_full_uid_complex_query.json
    ${file_without_replaced_vars}   Get File    ${expected_res_tmp}
    ${data_replaced_vars}    Replace Variables  ${file_without_replaced_vars}
    Log     Expected data: ${data_replaced_vars}
    Create File     ${EXPECTED_JSON_DATA_SETS}/select/expected_composition_full_uid_complex_query_tmp.json
    ...     ${data_replaced_vars}
    ${expected_result}      Set Variable    ${EXPECTED_JSON_DATA_SETS}/select/expected_composition_full_uid_complex_query_tmp.json
    ${exclude_paths}    Create List    root['meta']     root['q']   root['rows'][0][0]['uid']
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${expected_result}      exclude_paths=${exclude_paths}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!
    [Teardown]      Run Keywords
    ...     Remove File     ${EXPECTED_JSON_DATA_SETS}/select/expected_composition_full_uid_complex_query_tmp.json
    ...     AND     Admin Delete EHR For AQL


*** Keywords ***
Precondition
    Upload OPT For AQL      aql-conformance-ehrbase.org.v0.opt
    Create EHR For AQL
    Commit Composition For AQL      aql-conformance-ehrbase.org.v0_contains.json
    Set Test Variable       ${compo_id}     ${composition_short_uid}