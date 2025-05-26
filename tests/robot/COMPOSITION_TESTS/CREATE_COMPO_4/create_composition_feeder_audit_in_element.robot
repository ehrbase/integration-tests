*** Settings ***
Documentation   Composition Integration Tests
...             ${\n}Covers: https://vitagroup-ag.atlassian.net/browse/CDR-1937
Metadata        COMPOSITION

Resource        ../../_resources/keywords/composition_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot
Suite Setup     Set Library Search Order For Tests


*** Test Cases ***
Composition With Feeder Audit In Element
    [Tags]      Positive    not-ready   CDR-1937
    [Documentation]     - Based on issue: https://github.com/ehrbase/ehrbase/issues/1501
    ...                 - Jira ticket: https://vitagroup-ag.atlassian.net/browse/CDR-1937
    Upload OPT    all_types/cistec.openehr.body_weight.v1.opt
    create EHR
    commit composition   format=CANONICAL_JSON
    ...                  composition=composition_feeder_audit_in_element.json
    check the successful result of commit composition
    get composition by composition_uid    ${composition_uid}
    check composition exists
    [Teardown]  (admin) delete ehr