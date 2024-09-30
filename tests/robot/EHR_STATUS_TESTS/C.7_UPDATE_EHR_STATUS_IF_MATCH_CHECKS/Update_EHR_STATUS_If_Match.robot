*** Settings ***
Metadata    Author    *Vladislav Ploaia*
Metadata    Created    2024.09.05

Metadata        TOP_TEST_SUITE    EHR_STATUS

Resource        ../../_resources/keywords/ehr_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot
Suite Setup     Set Library Search Order For Tests



*** Test Cases ***
Update EHR Status - If-Match With Existing UUID
    prepare new request session    JSON    Prefer=return=representation
    create new EHR
    update EHR: set ehr_status is_queryable    ${TRUE}
    check response of 'update EHR' (JSON)
    [Teardown]      (admin) delete ehr

Update EHR Status - If-Match With Non-Existing UUID Version Number
    [Tags]      not-ready   CDR-1585
    [Documentation]     Update EHR_STATUS with If-Match value (non-existing version number).
    ...     Example: If-Match=1b6d2873-fcba-4fb6-b11e-13ce977b0666::local.ehrbase.org::2
    ...     Expect 412.
    ...     Check as well the Location and ETag keys presence in response headers from Update call.
    Create EHR - Extract EHR Data - Prepare For Update EHR_STATUS
    #set {ehrstatus_uid} with replaced version number (non-existing version number)
    ${ehr_status_uuid_non_existing_version}     Replace String
    ...     ${ehrstatus_uid}    ::1      ::2
    Set Suite Variable      ${ehrstatus_uid}   ${ehr_status_uuid_non_existing_version}
    ${err_msg}  Run Keyword And Expect Error    *
    ...     set ehr_status of EHR       multitenancy_token=${None}
    Should Contain      ${err_msg}      412 != 200
    Log     https://vitagroup-ag.atlassian.net/browse/CDR-1585
    Dictionary Should Contain Key   ${response.headers}     Location
    Dictionary Should Contain Key   ${response.headers}     ETag
    [Teardown]      (admin) delete ehr

Update EHR Status - If-Match With Non-Existing UID Value
    [Documentation]     Update EHR_STATUS with If-Match value (non-existing uid value).
    ...     Example: If-Match=2c7d2873-fcba-4fb6-c55r-13ce977b0547::local.ehrbase.org::1
    ...     Expect 412.
    Create EHR - Extract EHR Data - Prepare For Update EHR_STATUS
    #set {ehrstatus_uid} with replaced uid value (non-existing uid value)
    ${ehr_status_uuid_non_existing_value}     Replace String
    ...     ${ehrstatus_uid}    ${versioned_status_uid}     ${{str(uuid.uuid4())}}
    Set Suite Variable      ${ehrstatus_uid}   ${ehr_status_uuid_non_existing_value}
    ${err_msg}  Run Keyword And Expect Error    *
    ...     set ehr_status of EHR       multitenancy_token=${None}
    Should Contain      ${err_msg}      412 != 200
    [Teardown]      (admin) delete ehr

Update EHR Status - If-Match With Non-Existing UID Value - System Id - Version
    [Documentation]     Update EHR_STATUS with If-Match value (non-existing uid, system_id and version number).
    ...     Example: If-Match=049addcd-9094-4d3c-8b79-9bb62b38cac2::non-existing-system-id::6
    ...     Expect 412.
    Create EHR - Extract EHR Data - Prepare For Update EHR_STATUS
    #set {ehrstatus_uid} with replaced uid value (non-existing uid value)
    ${ehr_status_uuid_non_existing_value}     Replace String
    ...     ${ehrstatus_uid}    ${versioned_status_uid}     ${{str(uuid.uuid4())}}
    ${ehrstatus_uid}    Set Variable   ${ehr_status_uuid_non_existing_value}
    #set {ehrstatus_uid} with replaced original system_id with non-existing-system-id
    @{ehr_status_uid_list}      Split String    ${ehrstatus_uid}    ::
    Set Test Variable    ${initial_system_id}    ${ehr_status_uid_list}[1]
    ${ehr_status_system_id_non_existing_value}     Replace String
    ...     ${ehrstatus_uid}    ${initial_system_id}     non-existing-system-id
    #Set Suite Variable      ${ehrstatus_uid}   ${ehr_status_system_id_non_existing_value}
    ${ehrstatus_uid}    Set Variable   ${ehr_status_system_id_non_existing_value}
    ${ehr_status_non_existing_version}     Replace String
    ...     ${ehrstatus_uid}    ::1     ::5
    Set Suite Variable      ${ehrstatus_uid}   ${ehr_status_non_existing_version}
    ${err_msg}  Run Keyword And Expect Error    *
    ...     set ehr_status of EHR       multitenancy_token=${None}
    Should Contain      ${err_msg}      412 != 200
    [Teardown]      (admin) delete ehr

Update EHR Status - If-Match With Wrong Value
    [Tags]      not-ready   CDR-1586
    [Documentation]     Update EHR_STATUS with If-Match value (wrong format).
    ...     Example: If-Match=783beec5-9d29-4067-85b4-ad0884bc7c88::8
    ...     Expect 400.
    Create EHR - Extract EHR Data - Prepare For Update EHR_STATUS
    #set {ehrstatus_uid} with wrongly structured value (e.g. 783beec5-9d29-4067-85b4-ad0884bc7c88::8)
    Set Suite Variable      ${ehrstatus_uid}   ${versioned_status_uid}::8
    ${err_msg}  Run Keyword And Expect Error    *
    ...     set ehr_status of EHR       multitenancy_token=${None}
    Log     https://vitagroup-ag.atlassian.net/browse/CDR-1586
    Should Contain      ${err_msg}      400 != 200      #it returns 501 Not Implemented
    [Teardown]      (admin) delete ehr

Update EHR Status - Missing If-Match Header
    [Documentation]     Update EHR_STATUS with missing If-Match in headers.
    ...     Expect 400.
    Create EHR - Extract EHR Data - Prepare For Update EHR_STATUS
    #update EHR_STATUS without If-Match header
    &{headers}      Create Dictionary
    ...     Accept=application/json     Content-Type=application/json
    ...     Prefer=return=representation
    ${resp}         PUT On Session     ${SUT}    /ehr/${ehr_id}/ehr_status    json=${ehr_status}
                    ...     headers=${headers}      expected_status=anything
                    Set Test Variable    ${response}    ${resp}
                    Status Should Be    400
    [Teardown]      (admin) delete ehr


*** Keywords ***
Create EHR - Extract EHR Data - Prepare For Update EHR_STATUS
    prepare new request session    JSON    Prefer=return=representation
    create new EHR
    extract ehr_id from response (JSON)
    extract system_id from response (JSON)
    extract ehrstatus_uid (JSON)
    extract ehr_status from response (JSON)
    set is_queryable / is_modifiable    is_queryable=True