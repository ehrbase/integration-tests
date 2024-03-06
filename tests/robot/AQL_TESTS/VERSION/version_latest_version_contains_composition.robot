*** Settings ***
Documentation   VERSION[LATEST_VERSION] CONTAINS COMPOSITION
...             - Covers the following:
...             - https://github.com/ehrbase/AQL_Test_CASES/blob/main/VERSION_TEST_SUIT.md#versionlatest_version-contains-composition

Resource        ../../_resources/keywords/aql_keywords.robot
Resource        ../../_resources/keywords/contribution_keywords.robot
Resource        ../../_resources/keywords/composition_keywords.robot

Suite Setup     Precondition
Suite Teardown  Run Keywords    Admin Delete EHR For AQL    ${ehr_id1}  AND
                ...             Admin Delete EHR For AQL    ${ehr_id3}


*** Variables ***
${query1}   SELECT e/ehr_id/value, c/archetype_details/template_id/value, cv/uid/value, cv/commit_audit/time_committed/value FROM EHR e CONTAINS VERSION cv[LATEST_VERSION] CONTAINS COMPOSITION c ORDER BY cv/commit_audit/time_committed
${query2}   SELECT cv/uid/value, cv/contribution/id/value, cv/commit_audit/time_committed/value FROM VERSION cv[LATEST_VERSION] CONTAINS COMPOSITION c[openEHR-EHR-COMPOSITION.conformance_composition_.v0] ORDER BY cv/commit_audit/time_committed ASC



*** Test Cases ***
1. ${query1}
    ${expected_file}    Set Variable    latest_version_contains_composition_sanity_check.json
    ${actual_file}      Set Variable    ${EXPECTED_JSON_DATA_SETS}/version/${expected_file}
    ${tmp_file}         Set Variable    ${EXPECTED_JSON_DATA_SETS}/version/latest_version_contains_composition_sanity_check_tmp.json
    ${time_committed_composition1}   Get Composition Time Committed     ${compo_uid_1}
    ${time_committed_composition2}   Get Composition Time Committed     ${compo_uid_2_v3}
    ${time_committed_composition3}   Get Composition Time Committed     ${compo_uid_3_v2}
    ${time_committed_composition4}   Get Composition Time Committed     ${compo_uid_5}
    ${time_committed_composition5}   Get Composition Time Committed     ${compo_uid_7_v2}
    ${time_committed_composition6}   Get Composition Time Committed     ${compo_uid_8}
    Set AQL And Execute Ad Hoc Query    ${query1}
    ${file_without_replaced_vars}       Get File    ${actual_file}
    ${data_replaced_vars}    Replace Variables      ${file_without_replaced_vars}
                        Create File     ${tmp_file}     ${data_replaced_vars}
                        Length Should Be    ${resp_body['rows']}     6
    ${exclude_paths}    Create List    root['meta']     root['q']   root['rows'][0][0]['uid']
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${tmp_file}     exclude_paths=${exclude_paths}
                Should Be Empty     ${diff}    msg=DIFF DETECTED!
    [Teardown]  Remove File     ${tmp_file}

2. ${query2}
    ${expected_file}    Set Variable    latest_version_contains_composition_contribution_check.json
    ${actual_file}      Set Variable    ${EXPECTED_JSON_DATA_SETS}/version/${expected_file}
    ${tmp_file}         Set Variable    ${EXPECTED_JSON_DATA_SETS}/version/latest_version_contains_composition_contribution_check_tmp.json
    ${time_committed_composition5}   Get Composition Time Committed     ${compo_uid_5}
    ${time_committed_composition8}   Get Composition Time Committed     ${compo_uid_8}
    Set AQL And Execute Ad Hoc Query    ${query2}
    Set Suite Variable   ${contribution_id1}     ${resp_body['rows'][0][1]}
    Set Suite Variable   ${contribution_id2}     ${resp_body['rows'][1][1]}
    ${file_without_replaced_vars}       Get File    ${actual_file}
    ${data_replaced_vars}    Replace Variables      ${file_without_replaced_vars}
                        Create File     ${tmp_file}     ${data_replaced_vars}
                        Length Should Be    ${resp_body['rows']}     2
    ${exclude_paths}    Create List    root['meta']     root['q']   root['rows'][0][0]['uid']
    ${diff}     compare json-string with json-file
    ...     ${resp_body_actual}     ${tmp_file}     exclude_paths=${exclude_paths}
                Should Be Empty     ${diff}    msg=DIFF DETECTED!
    [Teardown]  Remove File     ${tmp_file}

3. Check Contributions Exists And Valid - Latest Version Composition
    Set Test Variable   ${contribution_uid}    ${contribution_id1}
    Set Test Variable   ${ehr_id}    ${ehr_id1}
    GET /ehr/ehr_id/contribution/contribution_uid   format=JSON
    Should Be Equal     ${response.status_code}     ${200}
    Should Be Equal     ${response.json()['versions'][0]['id']['value']}    ${compo_uid_5}
    Set Test Variable   ${contribution_uid}    ${contribution_id2}
    Set Test Variable   ${ehr_id}    ${ehr_id3}
    GET /ehr/ehr_id/contribution/contribution_uid   format=JSON
    Should Be Equal     ${response.status_code}     ${200}
    Should Be Equal     ${response.json()['versions'][0]['id']['value']}    ${compo_uid_8}


*** Keywords ***
Precondition
    Upload OPT For AQL      persistent_minimal.opt
    Upload OPT For AQL      conformance_ehrbase.de.v0.opt
    ###
    Create EHR For AQL
    Set Suite Variable      ${ehr_id1}  ${ehr_id}
    Commit Contribution For AQL     minimal_persistent/minimal_persistent.contribution.json
    Set Suite Variable      ${compo_uid_1}      ${versions[0]['id']['value']}
    Commit Composition For AQL      composition_file=persistent_minimal.en.v1__full.json
    Set Suite Variable      ${compo_uid_2}      ${composition_uid}
    Set Suite Variable      ${composition_id}   ${compo_uid_2}
    Update Composition For AQL      new_composition=persistent_minimal.en.v1__updated_v2.json
    Set Suite Variable      ${compo_uid_2_v2}   ${updated_version_composition_uid}
    Set Suite Variable      ${composition_id}   ${compo_uid_2_v2}
    Set Suite Variable      ${composition_uid}  ${compo_uid_2_v2}
    Update Composition For AQL      new_composition=persistent_minimal.en.v1__updated_v3.json
    Set Suite Variable      ${compo_uid_2_v3}   ${updated_version_composition_uid}
    Commit Composition For AQL      composition_file=persistent_minimal.en.v1__full.json
    Set Suite Variable      ${compo_uid_3}      ${composition_uid}
    Set Suite Variable      ${composition_id}   ${compo_uid_3}
    Update Composition For AQL      new_composition=persistent_minimal.en.v1__updated_v2.json
    Set Suite Variable      ${compo_uid_3_v2}   ${updated_version_composition_uid}
    Commit Composition For AQL      composition_file=persistent_minimal.en.v1__full.json
    Set Suite Variable      ${compo_uid_4}      ${composition_uid}
    Set Suite Variable      ${composition_id}   ${compo_uid_4}
    Delete Composition For AQL      composition_uid=${composition_id}
    Commit Composition For AQL      composition_file=conformance_ehrbase.de.v0_max.json
    Set Suite Variable      ${compo_uid_5}      ${composition_uid}
    ###
    Create EHR For AQL
    Set Suite Variable      ${ehr_id2}  ${ehr_id}
    Commit Composition For AQL      composition_file=persistent_minimal.en.v1__full.json
    Set Suite Variable      ${compo_uid_6}      ${composition_uid}
    Set Suite Variable      ${composition_id}   ${compo_uid_6}
    Delete Composition For AQL      composition_uid=${composition_id}
    Admin Delete EHR For AQL    ${ehr_id2}
    ###
    Create EHR For AQL
    Set Suite Variable      ${ehr_id3}  ${ehr_id}
    Set Suite Variable      ${ehr_status_id3}   ${response['body']['ehr_status']['uid']['value']}
    Update EHR Status For EHR
    ...     ehr_id=${ehr_id3}   ehrstatus_uid=${ehr_status_id3}     ehr_status_file=status3.json
    ###
    Commit Composition For AQL      composition_file=persistent_minimal.en.v1__full.json
    Set Suite Variable      ${compo_uid_7}      ${composition_uid}
    Set Suite Variable      ${composition_id}   ${compo_uid_7}
    Update Composition For AQL      new_composition=persistent_minimal.en.v1__updated_v2.json
    Set Suite Variable      ${compo_uid_7_v2}   ${updated_version_composition_uid}
    ###
    Commit Composition For AQL      composition_file=conformance_ehrbase.de.v0_max.json
    Set Suite Variable      ${compo_uid_8}      ${composition_uid}



