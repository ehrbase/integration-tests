*** Settings ***
Documentation   Composition Integration Tests
...             ${\n}Covers: https://vitagroup-ag.atlassian.net/browse/CDR-1937
Metadata        COMPOSITION

Resource        ../../_resources/keywords/composition_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot
Suite Setup     Set Library Search Order For Tests


*** Test Cases ***
Composition With Feeder Audit In Element
    [Tags]      Positive
    [Documentation]     - Based on issue: https://github.com/ehrbase/ehrbase/issues/1501
    ...                 - Covers Jira ticket: https://vitagroup-ag.atlassian.net/browse/CDR-1937
    Upload OPT    all_types/cistec.openehr.body_weight.v1.opt
    create EHR
    commit composition   format=CANONICAL_JSON
    ...                  composition=composition_feeder_audit_in_element.json
    Should Be Equal     ${response.status_code}     ${201}
    ${full_compo_uid}   Set Variable    ${response.json()['uid']['value']}
    ${short_compo_id}   Fetch From Left     ${full_compo_uid}    ::
    Set Test Variable   ${composition_uid}  ${short_compo_id}
    get composition by composition_uid    ${composition_uid}
    check composition exists
    [Teardown]  (admin) delete ehr