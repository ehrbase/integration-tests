*** Settings ***
Metadata        TOP_TEST_SUITE    DIRECTORY

Resource        ../../_resources/keywords/directory_keywords.robot
Resource        ../../_resources/keywords/ehr_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot
Suite Setup     Set Library Search Order For Tests
Test Setup      create EHR
Test Teardown   (admin) delete ehr


*** Test Cases ***
Update Directory - If-Match Value With Enclosed In Double Quotes
    [Tags]      Positive
    [Documentation]
    ...     Example: *If-Match="2c7d2873-fcba-4fb6-c55r-13ce977b0547::local.ehrbase.org::1"*
    ...     Expect 200.
    Create Directory And Expect 201
    Set Test Variable      ${preceding_version_uid}     \"${preceding_version_uid}\"
    Update Directory And Expect 200

Update Directory - If-Match Value Missing
    [Tags]      Negative
    [Documentation]
    ...     Example: *If-Match=*
    ...     Expect 400.
    Create Directory And Expect 201
    Set Test Variable      ${preceding_version_uid}     ${EMPTY}
    Update Directory And Expect 400

Update Directory - If-Match Value With Weak Validator Enclosed In Double Quotes
    [Tags]      Negative
    [Documentation]
    ...     Example: *If-Match=W/"{uid}::{system_id}::{version}"*
    ...     Expect 400.
    Create Directory And Expect 201
    Set Test Variable   ${preceding_version_uid}    W/\"${preceding_version_uid}\"
    Update Directory And Expect 400

Update Directory - If-Match Value With Weak Validator Without Double Quotes
    [Tags]      Negative
    [Documentation]
    ...     Example: *If-Match=W/{uid}::{system_id}::{version}*
    ...     Expect 400.
    Create Directory And Expect 201
    Set Test Variable   ${preceding_version_uid}    W/${preceding_version_uid}
    Update Directory And Expect 400

Update Directory - If-Match Value Asterisc
    [Tags]      Negative
    [Documentation]
    ...     Example: *If-Match=\**
    ...     Expect 400.
    Create Directory And Expect 201
    Set Test Variable   ${preceding_version_uid}    *
    Update Directory And Expect 400

Update Directory - If-Match Value Asterisc Enclosed In Double Quotes
    [Tags]      Negative
    [Documentation]
    ...     Example: *If-Match=\"*\"*
    ...     Expect 400.
    Create Directory And Expect 201
    Set Test Variable   ${preceding_version_uid}    \"*\"
    Update Directory And Expect 400

Update Directory - If-Match Value Without Closing Quote
    [Tags]      Negative
    [Documentation]
    ...     Example: *If-Match="{uid}::{system_id}::{version}*
    ...     Expect 400.
    Create Directory And Expect 201
    Set Test Variable   ${preceding_version_uid}    \"${preceding_version_uid}
    Update Directory And Expect 400

Update Directory - If-Match Value Without Opening Quote
    [Tags]      Negative
    [Documentation]
    ...     Example: *If-Match={uid}::{system_id}::{version}"*
    ...     Expect 400.
    Create Directory And Expect 201
    Set Test Variable   ${preceding_version_uid}    ${preceding_version_uid}\"
    Update Directory And Expect 400

Update Directory - If-Match Value Stray Quote
    [Tags]      Negative
    [Documentation]
    ...     Example: *If-Match="{uid}"::{system_id}::{version}"*
    ...     Expect 400.
    Create Directory And Expect 201
    @{split_preceding_version_id}      Split String    ${preceding_version_uid}    ::
    Set Test Variable   ${preceding_version_uid}
    ...     \"${split_preceding_version_id}[0]\"::${split_preceding_version_id}[1]::${split_preceding_version_id}[2]\"
    Update Directory And Expect 400

Update Directory - If-Match Value Is A List
    [Tags]      Negative
    [Documentation]
    ...     Example: *If-Match="{uid}::{system_id}::{version1}","{uid}::{system_id}::{version2}"*
    ...     Expect 400.
    Create Directory And Expect 201
    Set Test Variable   ${preceding_version_uid}    \"${preceding_version_uid}\",\"43b72792-bb42-490a-ac66-58e99b0be66d::local.ehrbase.org::2\"
    Update Directory And Expect 400

Update Directory - If-Match Value Is DirectoryId
    [Tags]      Negative
    [Documentation]
    ...     Example: *If-Match={uid}*
    ...     Expect 400.
    Create Directory And Expect 201
    @{split_preceding_version_id}      Split String    ${preceding_version_uid}    ::
    Set Test Variable   ${preceding_version_uid}    ${split_preceding_version_id}[0]
    Update Directory And Expect 400

Update Directory - If-Match Value With One Separator
    [Tags]      Negative
    [Documentation]
    ...     Example: *If-Match={uid}::{system_id}*
    ...     Expect 400.
    Create Directory And Expect 201
    @{split_preceding_version_id}      Split String    ${preceding_version_uid}    ::
    Set Test Variable   ${preceding_version_uid}
    ...     ${split_preceding_version_id}[0]::${split_preceding_version_id}[1]
    Update Directory And Expect 400

Update Directory - If-Match Value With Empty Object Id
    [Tags]      Negative
    [Documentation]
    ...     Example: *If-Match=::{system_id}::{version}*
    ...     Expect 400.
    Create Directory And Expect 201
    @{split_preceding_version_id}      Split String    ${preceding_version_uid}    ::
    Set Test Variable   ${preceding_version_uid}
    ...     ::${split_preceding_version_id}[1]::${split_preceding_version_id}[2]
    Update Directory And Expect 400

Update Directory - If-Match Value With Empty System Id
    [Tags]      Negative
    [Documentation]
    ...     Example: *If-Match={uid}::::{version}*
    ...     Expect 400.
    Create Directory And Expect 201
    @{split_preceding_version_id}      Split String    ${preceding_version_uid}    ::
    Set Test Variable   ${preceding_version_uid}
    ...     ${split_preceding_version_id}[0]::::${split_preceding_version_id}[2]
    Update Directory And Expect 400

Update Directory - If-Match Value With Empty Version
    [Tags]      Negative
    [Documentation]
    ...     Example: *If-Match={uid}::{system_id}::*
    ...     Expect 400.
    Create Directory And Expect 201
    @{split_preceding_version_id}      Split String    ${preceding_version_uid}    ::
    Set Test Variable   ${preceding_version_uid}
    ...     ${split_preceding_version_id}[0]::${split_preceding_version_id}[1]::
    Update Directory And Expect 400

Update Directory - If-Match Value With Four Segments
    [Tags]      Negative
    [Documentation]
    ...     Example: *If-Match={uid}::{system_id}::{version}::2*
    ...     Expect 400.
    Create Directory And Expect 201
    @{split_preceding_version_id}      Split String    ${preceding_version_uid}    ::
    Set Test Variable   ${preceding_version_uid}
    ...     ${split_preceding_version_id}[0]::${split_preceding_version_id}[1]::${split_preceding_version_id}[2]::2
    Update Directory And Expect 400

Update Directory - If-Match With Non-Existing UUID Version Number
    [Tags]      not-ready   CDR-1585    Negative
    [Documentation]     Update Directory with If-Match value (non-existing version number).
    ...     Example: If-Match=1b6d2873-fcba-4fb6-b11e-13ce977b0666::local.ehrbase.org::2
    ...     Expect 412.
    ...     Check as well the ETag key presence in response headers from Update call.
    Create Directory And Expect 201
    #set {preceding_version_uid} with replaced version number (non-existing version number)
    ${directory_uuid_non_existing_version}     Replace String
    ...     ${preceding_version_uid}    ::1      ::2
    Set Test Variable      ${preceding_version_uid}   ${directory_uuid_non_existing_version}
    Update Directory And Expect 412
    Log     CDR-1585
    Dictionary Should Contain Key   ${response.headers}     ETag

Update Directory - If-Match With Non-Existing UID Value
    [Tags]      Negative
    [Documentation]     Update Directory with If-Match value (non-existing uid value).
    ...     Example: If-Match=2c7d2873-fcba-4fb6-c55r-13ce977b0547::local.ehrbase.org::1
    ...     Expect 400.
    Create Directory And Expect 201
    @{temp_folder_uid_list}     Split String    ${preceding_version_uid}    ::
    Set Test Variable    ${folder_uid_without_system_and_version}    ${temp_folder_uid_list}[0]
    #set {preceding_version_uid} with replaced uid value (non-existing uid value)
    ${directory_uuid_non_existing_value}     Replace String
    ...     ${preceding_version_uid}    ${folder_uid_without_system_and_version}     ${{str(uuid.uuid4())}}
    Set Test Variable      ${preceding_version_uid}   ${directory_uuid_non_existing_value}
    Log     ${preceding_version_uid}
    Update Directory And Expect 400



*** Keywords ***
Create Directory And Expect 201
    create DIRECTORY (JSON)    empty_directory.json
    validate POST response - 201 created directory

Update Directory And Expect ${status_code}
    update DIRECTORY (JSON)    update/2_add_subfolders.json     isModifiable=${FALSE}
    Should Be Equal As Strings      ${response.status_code}     ${status_code}