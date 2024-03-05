*** Settings ***
Documentation   VERSION[LATEST_VERSION] CONTAINS EHR_STATUS
...             - Covers the following:
...             - https://github.com/ehrbase/AQL_Test_CASES/blob/main/VERSION_TEST_SUIT.md#versionlatest_version-contains-ehr_status

Resource        ../../_resources/keywords/aql_keywords.robot

Suite Setup     Precondition
Suite Teardown  Run Keywords    Admin Delete EHR For AQL    ${ehr_id1}  AND
                ...             Admin Delete EHR For AQL    ${ehr_id3}


*** Test Cases ***
Sanity Check
    Log     ${ehr_id1}, ${ehr_status_id1} \n ${ehr_id3}, ${ehr_status_id3}
    ${expected_file}    Set Variable    latest_version_contains_ehr_status_sanity_check.json
    ${actual_file}      Set Variable    ${EXPECTED_JSON_DATA_SETS}/version/${expected_file}
    ${tmp_file}         Set Variable    ${EXPECTED_JSON_DATA_SETS}/version/latest_version_contains_ehr_status_sanity_check_tmp.json
    ${query}    Catenate
                ...     SELECT cv/uid/value, cv/commit_audit/time_committed/value, cv/commit_audit/change_type/value,
                ...     cv/commit_audit/change_type/defining_code/code_string,
                ...     cv/commit_audit/change_type/defining_code/preferred_term,
                ...     cv/commit_audit/change_type/defining_code/terminology_id/value, s/subject/external_ref/id/value
                ...     FROM VERSION cv[LATEST_VERSION]
                ...     CONTAINS EHR_STATUS s
                ...     ORDER BY cv/commit_audit/time_committed ASC
    ${time_committed_ehr_status1}   Get EHR Status Time Committed   ${ehr_status_id1}
    ${time_committed_ehr_status2}   Get EHR Status Time Committed   ${ehr_status_id3_version2}
                        Set Test Variable   ${time_committed_ehr_status1}   ${time_committed_ehr_status1}
                        Set Test Variable   ${time_committed_ehr_status2}   ${time_committed_ehr_status2}
    Set AQL And Execute Ad Hoc Query        ${query}
    ${file_without_replaced_vars}       Get File    ${actual_file}
    ${data_replaced_vars}    Replace Variables      ${file_without_replaced_vars}
                        Create File     ${tmp_file}     ${data_replaced_vars}
                        Length Should Be    ${resp_body['rows']}     2
    ${exclude_paths}    Create List    root['meta']     root['q']   root['rows'][0][0]['uid']
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${tmp_file}     exclude_paths=${exclude_paths}
                Should Be Empty     ${diff}    msg=DIFF DETECTED!
    [Teardown]  Remove File     ${tmp_file}


*** Keywords ***
Precondition
    Create EHR For AQL
    Set Suite Variable       ${ehr_id1}    ${ehr_id}
    Set Suite Variable       ${ehr_status_id1}    ${response['body']['ehr_status']['uid']['value']}
    Set Suite Variable       ${ehr_status_id1_subject_external_ref_id}    ${response['body']['ehr_status']['subject']['external_ref']['id']['value']}
    Create EHR For AQL
    Set Suite Variable       ${ehr_id2}    ${ehr_id}
    Set Suite Variable       ${ehr_status_id2}    ${response['body']['ehr_status']['uid']['value']}
    Admin Delete EHR For AQL    ${ehr_id2}
    Create EHR For AQL
    Set Suite Variable       ${ehr_id3}    ${ehr_id}
    Set Suite Variable       ${ehr_status_id3}    ${response['body']['ehr_status']['uid']['value']}
    Update EHR Status For EHR
    ...     ehr_id=${ehr_id3}   ehrstatus_uid=${ehr_status_id3}     ehr_status_file=status3.json
    Set Suite Variable       ${ehr_status_id3_version2}    ${response.json()['uid']['value']}
    Set Suite Variable       ${ehr_status_id3_subject_external_ref_id}    ${response.json()['subject']['external_ref']['id']['value']}

Get EHR Status Time Committed
    [Arguments]     ${ehr_status_uid}
    ${query_to_get_time_committed}      Catenate
    ...     SELECT cv/commit_audit/time_committed/value
    ...     FROM VERSION cv[LATEST_VERSION]
    ...     CONTAINS EHR_STATUS s
    ...     WHERE cv/uid/value = '${ehr_status_uid}'
    Set AQL And Execute Ad Hoc Query    ${query_to_get_time_committed}
    [Return]    ${resp_body['rows'][0][0]}
