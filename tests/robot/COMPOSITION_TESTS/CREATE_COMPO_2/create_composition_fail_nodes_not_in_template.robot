*** Settings ***
Documentation   Validation test suite
...             ${\n}Covers fix provided in:
...             https://github.com/ehrbase/ehrbase/pull/1424
Metadata        TOP_TEST_SUITE    COMPOSITION

Resource        ../../_resources/keywords/composition_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot
Resource        ../../_resources/keywords/template_opt1.4_keywords.robot

Suite Setup       Run Keywords
...     Set Library Search Order For Tests  AND
...     Precondition


*** Test Cases ***
1. Create Composition Fails If Nodes Are Not Present In Template 1
    [Tags]      Negative    not-ready
    # To remove not-ready when latest ehrbase version is applied to HIP EHRBase develop
    Set Test Variable   ${template_id}          ${template_id_1}
    Set Test Variable   ${composition_file}     ${template_id}__.json
    commit composition      format=CANONICAL_JSON
    ...                     composition=${composition_file}
    Expect 422 Unprocessable Entity - not in template
    [Teardown]      Delete Template Using API

2. Create Composition Fails If Nodes Are Not Present In Template 2
    [Tags]      Negative    not-ready
    # To remove not-ready when latest ehrbase version is applied to HIP EHRBase develop
    Set Test Variable   ${template_id}          ${template_id_2}
    Set Test Variable   ${composition_file}     ${template_id}__.json
    commit composition      format=CANONICAL_JSON
    ...                     composition=${composition_file}
    Expect 422 Unprocessable Entity - not in template
    [Teardown]      Run Keywords
    ...     (admin) delete ehr   AND
    ...     Delete Template Using API


*** Keywords ***
Precondition
    Set Suite Variable   ${template_id_1}      nodes_in_template_invalid
    Set Suite Variable   ${template_id_2}      hc3_spirometry_test_result_v0.6
    Upload OPT    all_types/${template_id_1}.opt
    Upload OPT    all_types/${template_id_2}.opt
    create EHR

Expect 422 Unprocessable Entity - Not In Template
    Should Be Equal As Strings      ${response.status_code}     422
    Should Be Equal As Strings      ${response.json()['error']}     Unprocessable Entity
    Should Contain      ${response.json()['message']}   not in template