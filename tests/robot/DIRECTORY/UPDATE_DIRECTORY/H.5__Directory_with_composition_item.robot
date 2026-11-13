*** Settings ***
Metadata        TOP_TEST_SUITE    DIRECTORY

Resource        ../../_resources/keywords/directory_keywords.robot
Resource        ../../_resources/keywords/ehr_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot
Resource        ../../_resources/keywords/composition_keywords.robot
Suite Setup     Set Library Search Order For Tests
Test Setup      create EHR
Test Teardown   Delete EHR And Template


*** Test Cases ***
Update Directory - Updated Composition - Prevent Duplicated Items Entries In Root Directory
    Upload OPT    minimal/persistent_minimal.en.v1.opt
    commit composition   format=CANONICAL_JSON
    ...                  composition=persistent_minimal.en.v1__full.json
    check the successful result of commit composition
    @{split_compositionUid}     Split String    ${compositionUid}    ::
    ${composition_id}   Set Variable        ${split_compositionUid}[0]
    Set Test Variable   ${composition_id}   ${composition_id}
    Set Test Variable   ${template_id}  persistent_minimal.en.v1
    Create Directory And Perform Checks
    Update Composition And Perform Checks
    Update Directory And Perform Checks




*** Keywords ***
Delete EHR And Template
    (admin) delete ehr
    Delete Template Using API

Check Folder To Contain One Items With Correct Composition
    Length Should Be     ${response.json()['items']}    1
    Dictionary Should Not Contain Key     ${response.json()['items'][0]}    folders
    Should Be Equal      ${response.json()['items'][0]['type']}    VERSIONED_COMPOSITION
    Should Be Equal      ${response.json()['items'][0]['id']['value']}    ${composition_id}

Create Directory And Perform Checks
    create DIRECTORY (JSON)    folder_with_existing_composition_root_directory.json
    get DIRECTORY (JSON)
    validate GET response - 200 retrieved
    Check Folder To Contain One Items With Correct Composition

Update Composition And Perform Checks
    update composition (JSON)   persistent_minimal.en.v1__full_without_links.json
    ...     file_type=json
    Should Be Equal As Strings  ${response.status_code}    200
    get DIRECTORY (JSON)
    validate GET response - 200 retrieved
    Check Folder To Contain One Items With Correct Composition

Update Directory And Perform Checks
    update DIRECTORY (JSON)    folder_with_existing_composition_root_directory_and_details.json
    validate PUT response - 200 updated
    get DIRECTORY (JSON)
    validate GET response - 200 retrieved
    Check Folder To Contain One Items With Correct Composition