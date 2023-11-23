*** Settings ***
Documentation   CHECK AQL RESPONSE ON FROM EHR_STATUS, test from multiple ehrs
...             - Covers: https://github.com/ehrbase/AQL_Test_CASES/blob/main/FROM_TEST_SUIT.MD#test-from-multiple-ehrs
...         - *Precondition:* 1. Create EHRs with Status from status1.json and status2.json; 2. Save {ehr_id1}, {ehr_id2};
...         - Send AQL 'SELECT s/subject/external_ref/id/value, s/other_details/items[at0001]/value/id FROM EHR e CONTAINS EHR_STATUS s'
...         - Check AQL result to be {ins1920,55175056}, {ins1921,55175057}
...         - *Postcondition:* Delete EHR using ADMIN endpoint.
Resource        ../../../_resources/keywords/aql_keywords.robot

#Suite Setup  Skip    enable Setup 'Precondition' if AQL checks are passing !!!
#Suite Teardown  Skip    enable Teardown 'Admin Delete EHR For AQL' if AQL checks are passing !!!
Suite Setup     Precondition        #enable this keyword if AQL checks are passing !!!
Suite Teardown  Run Keywords
...     Admin Delete EHR For AQL    ${ehr_id1}      AND
...     Admin Delete EHR For AQL    ${ehr_id2}


*** Test Cases ***
SELECT s/subject/external_ref/id/value, s/other_details/items[at0001]/value/id FROM EHR e CONTAINS EHR_STATUS s
    ${query}    Set Variable    SELECT s/subject/external_ref/id/value, s/other_details/items[at0001]/value/id FROM EHR e CONTAINS EHR_STATUS s
    Set AQL And Execute Ad Hoc Query        ${query}
    ${expected_result}      Set Variable    ${EXPECTED_JSON_DATA_SETS}/from/ehr_status_from_multiple_ehrs.json
    Length Should Be    ${resp_body['rows']}     2
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${expected_result}
    ...     ignore_order=${TRUE}    ignore_string_case=${TRUE}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!


*** Keywords ***
Precondition
    Create EHR For AQL With Custom EHR Status       file_name=status1.json
    Set Suite Variable       ${ehr_id1}    ${ehr_id}
    Create EHR For AQL With Custom EHR Status       file_name=status2.json
    Set Suite Variable       ${ehr_id2}    ${ehr_id}