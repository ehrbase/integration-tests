*** Settings ***
Documentation
...     Covers: https://vitagroup-ag.atlassian.net/browse/CDR-1688
...     Preconditions:
...         1. Upload OPT
...         2. Create EHR
...         3. Commit Composition
...
...     Flow:
...         - Invoke the create directory with 1 item "type": "COMPOSITION" (the one created in precondition)
...
...     Postconditions:
...         - Delete EHR
Metadata        TOP_TEST_SUITE    DIRECTORY

Resource        ../../_resources/keywords/directory_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot
Resource        ../../_resources/keywords/ehr_keywords.robot
Resource        ../../_resources/keywords/composition_keywords.robot
Suite Setup     Set Library Search Order For Tests


*** Test Cases ***
Test Add Composition To Folder
    [Tags]      CDR-1688    not-ready   bug
    [Setup]     Precondition
    Get File And Replace Vars
    ${exists}   Run Keyword And Return Status    Variable Should Exist    ${multitenancy_token}
    IF      ${exists}
        POST /ehr/ehr_id/directory    JSON      ${multitenancy_token}
    ELSE
        POST /ehr/ehr_id/directory    JSON
    END
    validate POST response - 201 created directory
    [Teardown]      Run Keywords    (admin) delete ehr
    ...             AND             (admin) delete all OPTs



*** Keywords ***
Precondition
    Set Library Search Order For Tests
    Upload OPT    nested/nested.opt
    Extract Template Id From OPT File
    Create Session      ${SUT}    ${BASEURL}    debug=2
    ...     verify=True
    create EHR
    ##
    commit composition   format=CANONICAL_JSON
    ...                  composition=nested.en.v1__full_without_links.json
    Set Suite Variable      ${composition_uid}   ${response.json()['uid']['value']}
    @{split_compo_id}   Split String        ${composition_uid}      ::
    ${composition_id}   Set Variable        ${split_compo_id}[0]
    Set Suite Variable      ${compo_id}    ${composition_id}

Get File And Replace Vars
    ${json_str}             Get File    ${VALID DIR DATA SETS}/subfolder_in_directory_with_compo_item.json
    ${json_str_replaced}    Replace Variables   ${json_str}
    ${json_converted}       Evaluate    json.loads('''${json_str_replaced}''')    json
                            Set Suite Variable      ${test_data}    ${json_converted}
                            Log     ${test_data}