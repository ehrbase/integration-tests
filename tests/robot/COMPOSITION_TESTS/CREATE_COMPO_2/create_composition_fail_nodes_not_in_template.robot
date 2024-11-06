*** Settings ***
Documentation   Validation test suite
...             ${\n}Covers fix provided in:
...             https://github.com/ehrbase/ehrbase/pull/1424
Metadata        TOP_TEST_SUITE    COMPOSITION

Resource        ../../_resources/keywords/composition_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot
Resource        ../../_resources/keywords/template_opt1.4_keywords.robot

Suite Setup       Set Library Search Order For Tests


*** Variables ***
${opt_file}             nodes_in_template_invalid.opt
${composition_file}     nodes_in_template_invalid__compo.json
${template_id}          nodes_in_template_invalid


*** Test Cases ***
Create Composition Fails If Nodes Are Not Present In Template
    [Tags]      Negative
    Upload OPT    all_types/nodes_in_template_invalid.opt
    create EHR
    commit composition      format=CANONICAL_JSON
    ...                     composition=${composition_file}
    Should Be Equal As Strings      ${response.status_code}     422
    Should Be Equal As Strings      ${response.json()['error']}     Unprocessable Entity
    Should Contain      ${response.json()['message']}    not in template
    [Teardown]      Run Keywords
    ...     (admin) delete ehr   AND
    ...     Delete Template Using API