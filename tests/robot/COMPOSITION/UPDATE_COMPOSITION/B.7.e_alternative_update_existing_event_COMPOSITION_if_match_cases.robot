*** Settings ***
Documentation   Composition Integration Tests
...             - Covers: https://vitagroup-ag.atlassian.net/browse/CDR-2498
Metadata        TOP_TEST_SUITE    COMPOSITION

Resource        ../../_resources/keywords/composition_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot
Suite Setup     Run Keywords
...             Set Library Search Order For Tests      AND
...             Upload OPT      minimal/minimal_observation.opt
Test Setup      create EHR
Test Teardown   (admin) delete ehr
Suite Teardown  (admin) delete all OPTs

Force Tags


*** Variables ***
${commit_compo_file}    minimal/minimal_observation.composition.participations.extdatetimes.xml
${update_compo_file}    minimal/minimal_observation.composition.participations.extdatetimes.v2.xml


*** Test Cases ***
Update Compo Allowed - If-Match Value Enclosed In Double Quotes
    [Tags]      Positive
    [Documentation]     *If-Match="{uid}::{system_id}::{version}"*
    commit composition (JSON)    ${commit_compo_file}
    check content of composition (JSON)
    update composition (JSON)    ${update_compo_file}
    check content of updated composition (JSON)
    Set Test Variable   ${preceding_version_uid}    \"${version_uid_v2}\"
    update composition (JSON)    ${update_compo_file}
    check content of updated composition (JSON)

Update Compo Not Allowed - If-Match Value Missing
    [Tags]      Negative
    [Documentation]     *If-Match=*
    commit composition (JSON)    ${commit_compo_file}
    check content of composition (JSON)
    Set Test Variable   ${preceding_version_uid}    ${EMPTY}
    Update Composition And Expect Precondition Failed

Update Compo Not Allowed - If-Match With Weak Validator Enclosed In Double Quotes
    [Tags]      Negative
    [Documentation]     *If-Match=W/"{uid}::{system_id}::{version}"*
    commit composition (JSON)    ${commit_compo_file}
    check content of composition (JSON)
    Set Test Variable   ${preceding_version_uid}    W/\"${preceding_version_uid}\"
    Update Composition And Expect Precondition Failed

Update Compo Not Allowed - If-Match With Weak Validator Without Double Quotes
    [Tags]      Negative
    [Documentation]     *If-Match=W/{uid}::{system_id}::{version}*
    commit composition (JSON)    ${commit_compo_file}
    check content of composition (JSON)
    Set Test Variable   ${preceding_version_uid}    W/${preceding_version_uid}
    Update Composition And Expect Precondition Failed

Update Compo Not Allowed - If-Match Asterisc
    [Tags]      Negative
    [Documentation]     *If-Match=\**
    commit composition (JSON)    ${commit_compo_file}
    check content of composition (JSON)
    Set Test Variable   ${preceding_version_uid}    *
    Update Composition And Expect Precondition Failed

Update Compo Not Allowed - If-Match Asterisc Enclosed In Double Quotes
    [Tags]      Negative
    [Documentation]     *If-Match=\"*\"*
    commit composition (JSON)    ${commit_compo_file}
    check content of composition (JSON)
    Set Test Variable   ${preceding_version_uid}    \"*\"
    Update Composition And Expect Precondition Failed

Update Compo Not Allowed - If-Match Value Without Closing Quote
    [Tags]      Negative
    [Documentation]     *If-Match="{uid}::{system_id}::{version}*
    commit composition (JSON)    ${commit_compo_file}
    check content of composition (JSON)
    Set Test Variable   ${preceding_version_uid}    \"${preceding_version_uid}
    Update Composition And Expect Precondition Failed

Update Compo Not Allowed - If-Match Value Without Opening Quote
    [Tags]      Negative
    [Documentation]     *If-Match={uid}::{system_id}::{version}"*
    commit composition (JSON)    ${commit_compo_file}
    check content of composition (JSON)
    Set Test Variable   ${preceding_version_uid}    ${preceding_version_uid}\"
    Update Composition And Expect Precondition Failed

Update Compo Not Allowed - If-Match Value Stray Quote
    [Tags]      Negative
    [Documentation]     *If-Match="{uid}"::{system_id}::{version}"*
    commit composition (JSON)    ${commit_compo_file}
    check content of composition (JSON)
    @{split_preceding_version_id}      Split String    ${preceding_version_uid}    ::
    Set Test Variable   ${preceding_version_uid}
    ...     \"${split_preceding_version_id}[0]\"::${split_preceding_version_id}[1]::${split_preceding_version_id}[2]\"
    Update Composition And Expect Precondition Failed

Update Compo Not Allowed - If-Match Value Is A List
    [Tags]      Negative
    [Documentation]     *If-Match="{uid}::{system_id}::{version1}","{uid}::{system_id}::{version2}"*
    commit composition (JSON)    ${commit_compo_file}
    check content of composition (JSON)
    update composition (JSON)    ${update_compo_file}
    check content of updated composition (JSON)
    Set Test Variable   ${preceding_version_uid}    \"${version_uid_v1}\",\"${version_uid_v2}\"
    Update Composition And Expect Precondition Failed

Update Compo Not Allowed - If-Match Value Is CompoId
    [Tags]      Negative
    [Documentation]     *If-Match={uid}*
    commit composition (JSON)    ${commit_compo_file}
    check content of composition (JSON)
    Set Test Variable   ${preceding_version_uid}    ${compo_uid_v1}
    Update Composition And Expect Precondition Failed

Update Compo Not Allowed - If-Match Value With One Separator
    [Tags]      Negative
    [Documentation]     *If-Match={uid}::{system_id}*
    commit composition (JSON)    ${commit_compo_file}
    check content of composition (JSON)
    @{split_preceding_version_id}      Split String    ${preceding_version_uid}    ::
    Set Test Variable   ${preceding_version_uid}
    ...     ${split_preceding_version_id}[0]::${split_preceding_version_id}[1]
    Update Composition And Expect Precondition Failed

Update Compo Not Allowed - If-Match Value With Empty Object Id
    [Tags]      Negative
    [Documentation]     *If-Match=::{system_id}::{version}*
    commit composition (JSON)    ${commit_compo_file}
    check content of composition (JSON)
    @{split_preceding_version_id}      Split String    ${preceding_version_uid}    ::
    Set Test Variable   ${preceding_version_uid}
    ...     ::${split_preceding_version_id}[1]::${split_preceding_version_id}[2]
    Update Composition And Expect Precondition Failed

Update Compo Not Allowed - If-Match Value With Empty System Id
    [Tags]      Negative
    [Documentation]     *If-Match={uid}::::{version}*
    commit composition (JSON)    ${commit_compo_file}
    check content of composition (JSON)
    @{split_preceding_version_id}      Split String    ${preceding_version_uid}    ::
    Set Test Variable   ${preceding_version_uid}
    ...     ${split_preceding_version_id}[0]::::${split_preceding_version_id}[2]
    Update Composition And Expect Precondition Failed

Update Compo Not Allowed - If-Match Value With Empty Version
    [Tags]      Negative
    [Documentation]     *If-Match={uid}::{system_id}::*
    commit composition (JSON)    ${commit_compo_file}
    check content of composition (JSON)
    @{split_preceding_version_id}      Split String    ${preceding_version_uid}    ::
    Set Test Variable   ${preceding_version_uid}
    ...     ${split_preceding_version_id}[0]::${split_preceding_version_id}[1]::
    Update Composition And Expect Precondition Failed

Update Compo Not Allowed - If-Match Value With Four Segments
    [Tags]      Negative
    [Documentation]     *If-Match={uid}::{system_id}::{version}::2*
    commit composition (JSON)    ${commit_compo_file}
    check content of composition (JSON)
    @{split_preceding_version_id}      Split String    ${preceding_version_uid}    ::
    Set Test Variable   ${preceding_version_uid}
    ...     ${split_preceding_version_id}[0]::${split_preceding_version_id}[1]::${split_preceding_version_id}[2]::2
    Update Composition And Expect Precondition Failed


*** Keywords ***
Update Composition And Expect Precondition Failed
    Run Keyword And Return Status   update composition (JSON)    ${update_compo_file}
    Should Be Equal     ${response.status_code}     ${412}
    Should Be Equal     ${response.json()['error']}     Precondition Failed