*** Settings ***
Documentation   Commit audit headers on a composition update: the REST 1.1.0 headers, the deprecated 1.0.3 headers,
...             and both together. Each update asks for amendment (250), which a create can't record, and reads the
...             `commit_audit` of version 2 back.
Metadata        TOP_TEST_SUITE    COMPOSITION

Resource        ../../_resources/keywords/composition_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot

Suite Setup     Precondition
Suite Teardown  (admin) delete all OPTs
Test Setup      create a composition
Test Teardown   (admin) delete ehr

Force Tags      audit-headers


*** Variables ***
${COMMITTER_ID}             BC8132EA-8F4A-11E7-BB31-BE2E44B06B34
${COMMITTER_REF}            committer.external_ref.id="${COMMITTER_ID}",committer.external_ref.namespace="demographic",committer.external_ref.type="PERSON"
${COMMITTER_REF_1_0_3}      external_ref.id="${COMMITTER_ID}",external_ref.namespace="demographic",external_ref.type="PERSON"


*** Test Cases ***
Update With The 1.1.0 Headers
    update the composition with
    ...    openehr-version=lifecycle_state.code_string="532"
    ...    openehr-audit-details=change_type.code_string="250",description.value="1.1.0 headers",committer.name="Jane Doe",${COMMITTER_REF}
    the commit audit of version 2 should have    Jane Doe    1.1.0 headers

Update With The 1.0.3 Headers
    [Tags]    legacy-header-names
    update the composition with
    ...    openEHR-VERSION.lifecycle_state=code_string="532"
    ...    openEHR-AUDIT_DETAILS.change_type=code_string="250"
    ...    openEHR-AUDIT_DETAILS.description=value="1.0.3 headers"
    ...    openEHR-AUDIT_DETAILS.committer=name="John Roe",${COMMITTER_REF_1_0_3}
    the commit audit of version 2 should have    John Roe    1.0.3 headers

Update With Different Keys In The 1.1.0 And 1.0.3 Headers
    [Tags]    legacy-header-names
    update the composition with
    ...    openehr-audit-details=committer.name="Mia Mix",${COMMITTER_REF}
    ...    openEHR-AUDIT_DETAILS.change_type=code_string="250"
    ...    openEHR-AUDIT_DETAILS.description=value="both header forms"
    the commit audit of version 2 should have    Mia Mix    both header forms

Update With The Same Key In The 1.1.0 And 1.0.3 Headers Is Rejected
    [Tags]    legacy-header-names
    update the composition with
    ...    openehr-audit-details=description.value="1.1.0 description"
    ...    openEHR-AUDIT_DETAILS.description=value="1.0.3 description"
    the update should be rejected with    duplicate key [value]

Update With Another System Id Than The Server's Is Rejected
    update the composition with    openehr-audit-details=system_id="other.system"
    the update should be rejected with    system_id [other.system] does not match the system id of this server


*** Keywords ***
Precondition
    Set Library Search Order For Tests
    Upload OPT    minimal/minimal_evaluation.opt

create a composition
    [Documentation]     Creates an EHR with one composition; its version uid is kept as `${composition_uid}`.
    create EHR
    commit composition    format=CANONICAL_JSON    composition=minimal_evaluation.en.v1__.json
    Should Be Equal As Strings    ${response.status_code}    201
    Set Test Variable    ${composition_uid}    ${response.json()}[uid][value]
    @{uid}=     Split String    ${composition_uid}    ::
    Set Test Variable    ${versioned_object_uid}    ${uid}[0]
    Set Test Variable    ${composition}    ${response.text}

update the composition with
    [Documentation]     Sends the composition again as version 2 with the given headers.
    [Arguments]         &{audit_headers}
    &{headers}=     Create Dictionary    Content-Type=application/json    Accept=application/json
    ...             Prefer=return=representation    If-Match=${composition_uid}    &{audit_headers}
    ${resp}=        PUT On Session    ${SUT}    /ehr/${ehr_id}/composition/${versioned_object_uid}
    ...             data=${composition}    headers=${headers}    expected_status=anything
    Set Test Variable    ${response}    ${resp}

the commit audit of version 2 should have
    [Documentation]     Checks amendment, the description and the committer in the `commit_audit` of version 2.
    [Arguments]         ${committer_name}    ${description}
    Should Be Equal As Strings    ${response.status_code}    200
    get version of versioned composition of EHR by UID    ${versioned_object_uid}    ${response.json()}[uid][value]
    Should Be Equal As Strings    ${response.status_code}    200
    ${audit}=       Set Variable    ${response.json()}[commit_audit]
    Should Be Equal    ${audit}[change_type][defining_code][code_string]    250
    Should Be Equal    ${audit}[description][value]    ${description}
    Should Be Equal    ${audit}[committer][name]    ${committer_name}
    Should Be Equal    ${audit}[committer][external_ref][id][value]    ${COMMITTER_ID}
    Should Be Equal    ${audit}[committer][external_ref][id][scheme]    DEMOGRAPHIC
    Should Be Equal    ${audit}[committer][external_ref][namespace]    demographic
    Should Be Equal    ${audit}[committer][external_ref][type]    PERSON

the update should be rejected with
    [Documentation]     Checks the 400 and its message, and that the composition is still at version 1.
    [Arguments]         ${message}
    Should Be Equal As Strings    ${response.status_code}    400
    Should Contain    ${response.text}    ${message}
    &{headers}=     Create Dictionary    Accept=application/json
    ${resp}=        GET On Session    ${SUT}    /ehr/${ehr_id}/composition/${versioned_object_uid}    headers=${headers}
    Should Be Equal    ${resp.json()}[uid][value]    ${composition_uid}
