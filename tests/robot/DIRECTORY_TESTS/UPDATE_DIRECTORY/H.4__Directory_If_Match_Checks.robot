*** Settings ***
Metadata        TOP_TEST_SUITE    DIRECTORY

Resource        ../../_resources/keywords/directory_keywords.robot
Resource        ../../_resources/keywords/ehr_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot
Suite Setup     Set Library Search Order For Tests


*** Test Cases ***
Update Directory - If-Match With Non-Existing UUID Version Number
    [Tags]      not-ready   CDR-1585
    [Documentation]     Update Directory with If-Match value (non-existing version number).
    ...     Example: If-Match=1b6d2873-fcba-4fb6-b11e-13ce977b0666::local.ehrbase.org::2
    ...     Expect 412.
    ...     Check as well the Location and ETag keys presence in response headers from Update call.
    create EHR
    create DIRECTORY (JSON)    empty_directory.json
    validate POST response - 201 created directory
    #set {preceding_version_uid} with replaced version number (non-existing version number)
    ${directory_uuid_non_existing_version}     Replace String
    ...     ${preceding_version_uid}    ::1      ::2
    Set Suite Variable      ${preceding_version_uid}   ${directory_uuid_non_existing_version}
    update DIRECTORY (JSON)    update/2_add_subfolders.json     isModifiable=${FALSE}
    Should Be Equal     ${response.status_code}     ${412}
    Log     https://vitagroup-ag.atlassian.net/browse/CDR-1585
    Dictionary Should Contain Key   ${response.headers}     Location
    Dictionary Should Contain Key   ${response.headers}     ETag
    [Teardown]    (admin) delete ehr

Update Directory - If-Match With Non-Existing UID Value
    [Tags]      not-ready   CDR-1580
    [Documentation]     Update Directory with If-Match value (non-existing uid value).
    ...     Example: If-Match=2c7d2873-fcba-4fb6-c55r-13ce977b0547::local.ehrbase.org::1
    ...     Expect 412.
    create EHR
    create DIRECTORY (JSON)    empty_directory.json
    validate POST response - 201 created directory
    @{temp_folder_uid_list}     Split String    ${preceding_version_uid}    ::
    Set Test Variable    ${folder_uid_without_system_and_version}    ${temp_folder_uid_list}[0]
    #set {preceding_version_uid} with replaced uid value (non-existing uid value)
    ${directory_uuid_non_existing_value}     Replace String
    ...     ${preceding_version_uid}    ${folder_uid_without_system_and_version}     ${{str(uuid.uuid4())}}
    Set Suite Variable      ${preceding_version_uid}   ${directory_uuid_non_existing_value}
    Log     ${preceding_version_uid}
    update DIRECTORY (JSON)    update/2_add_subfolders.json     isModifiable=${FALSE}
    Log     https://vitagroup-ag.atlassian.net/browse/CDR-1580
    Should Be Equal     ${response.status_code}     ${412}
    [Teardown]    (admin) delete ehr

Update Directory - If-Match With Wrong Value
    [Tags]      not-ready   CDR-1586
    [Documentation]     Update Directory with If-Match value (wrong format).
    ...     Example: If-Match=783beec5-9d29-4067-85b4-ad0884bc7c88::5
    ...     Expect 400.
    create EHR
    create DIRECTORY (JSON)    empty_directory.json
    validate POST response - 201 created directory
    #set {preceding_version_uid} with wrongly structured value (e.g. 783beec5-9d29-4067-85b4-ad0884bc7c88::5)
    Set Suite Variable      ${preceding_version_uid}    ${{str(uuid.uuid4())}}::5
    update DIRECTORY (JSON)    update/2_add_subfolders.json     isModifiable=${FALSE}
    Log     https://vitagroup-ag.atlassian.net/browse/CDR-1586
    Should Be Equal     ${response.status_code}     ${400}
    [Teardown]    (admin) delete ehr