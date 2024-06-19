*** Settings ***
Documentation   Test suite to check Basic EHR_STATUS Tags functionality.
...             \nCovers https://vitagroup-ag.atlassian.net/browse/CDR-1451
...             \nCovers below operations on EHR_STATUS Tags:
...             - 1. Create EHR_STATUS Tag - PUT /ehrbase/rest/experimental/tags/ehr/{ehr_id}/ehr_status/{ehr_status_uid}/item_tag
...             - 2. Get EHR_STATUS Tag - GET /ehrbase/rest/experimental/tags/ehr/{ehr_id}/ehr_status/{ehr_status_uid}/item_tag
...             - 3. Update EHR_STATUS Tag - PUT /ehrbase/rest/experimental/tags/ehr/{ehr_id}/ehr_status/{ehr_status_uid}/item_tag (with id in body)
...             - 4. Delete EHR_STATUS Tag - DELETE /ehrbase/rest/experimental/tags/ehr/{ehr_id}/ehr_status/{ehr_status_uid}/item_tag

Resource        ${EXECDIR}/robot/_resources/suite_settings.robot
Resource        ${EXECDIR}/robot/_resources/keywords/ehr_keywords.robot
Resource        ${EXECDIR}/robot/_resources/keywords/admin_keywords.robot
Suite Setup 		Set Library Search Order For Tests


*** Variables ***
${VALID EHR DATA SETS}       ${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/ehr/valid


*** Test Cases ***
1. Create EHR_STATUS Tag
    #Expect 200 on Create EHR_STATUS Tag
    [Tags]      Positive
    [Setup]     Precondition Create EHR With EHR_STATUS
    Create Session For EHR_STATUS Tag Calls
    Create EHR_STATUS Tag Call
    Set Suite Variable      ${EHR_STATUS_TAG_ID_1}  ${EHR_STATUS_TAG_ID}
    Default Checks For Tag Response

2. Retrieve EHR_STATUS Tag
    #Expect 200 on Retrieve EHR_STATUS Tag
    [Tags]      Positive
    Get EHR_STATUS Tag Call
    Set Test Variable       ${firstRespArrEl}       ${resp.json()[0]}
    Default Checks For Tag Response
    Create EHR_STATUS Tag Call
    Set Suite Variable      ${EHR_STATUS_TAG_ID_2}  ${EHR_STATUS_TAG_ID}
    Get EHR_STATUS Tag Call
    Length Should Be    ${resp.json()}    2

3. Update EHR_STATUS Tag
    #Expect 200 on Update EHR_STATUS Tag
    [Tags]      Positive
    Set Test Variable   ${tag_key}      1111111111
    Set Test Variable   ${tag_value}    EHR STATUS test value modified
    &{ehr_status_tag_body}      Create Dictionary
    ...     key=${tag_key}
    ...     value=${tag_value}
    ...     target_path=/name/value/temp
    ...     id=${EHR_STATUS_TAG_ID_2}
    Update EHR_STATUS Tag Call      custom_tag_body=${ehr_status_tag_body}
    Should Be Equal     ${firstRespArrEl['id']}     ${EHR_STATUS_TAG_ID_2}
    Should Be Equal     ${firstRespArrEl['target_path']}    /name/value/temp
    Should Be Equal     ${firstRespArrEl['key']}    ${tag_key}
    Should Be Equal     ${firstRespArrEl['value']}  ${tag_value}
    Get EHR_STATUS Tag Call
    Length Should Be    ${resp.json()}    2

4. Delete EHR_STATUS Tag
    #Expect 204 on Delete EHR_STATUS Tag
    [Tags]      Positive
    @{tags_ids_list}    Create List     ${EHR_STATUS_TAG_ID_1}      ${EHR_STATUS_TAG_ID_2}
    Delete EHR_STATUS Tag Call      ehr_status_ids_list=${tags_ids_list}
    Get EHR_STATUS Tag Call
    Should Be True      ${resp.content}     ${EMPTY}
    [Teardown]      (admin) delete ehr

5. Delete EHR Without Deleting EHR_STATUS Tag
    # Delete EHR without deleting EHR_STATUS Tag should pass and return 204.
    [Tags]      Negative
    [Setup]     Precondition Create EHR With EHR_STATUS
    Create Session For EHR_STATUS Tag Calls
    Create EHR_STATUS Tag Call
    Set Suite Variable      ${EHR_STATUS_TAG_ID_TEMP}      ${EHR_STATUS_TAG_ID}
    @{tags_ids_list}    Create List     ${EHR_STATUS_TAG_ID_TEMP}
    (admin) delete ehr
    ${err_msg}  Run Keyword And Expect Error    *
    ...     Delete EHR_STATUS Tag Call      ${tags_ids_list}
    Should Contain      ${err_msg}      404 != 204

6. Create EHR_STATUS Tag Without Key In Body
    # Create EHR_STATUS Tag without "key" in JSON body and expect 422 Unprocessable Entity as "key" is mandatory.
    [Tags]      Negative
    [Setup]     Precondition Create EHR With EHR_STATUS
    Create Session For EHR_STATUS Tag Calls
    &{ehr_status_tag_body}      Create Dictionary
    ...     value=${tag_value}
    ...     target_path=/name/value/temp
    ${err_msg}  Run Keyword And Expect Error    *
    ...     Create EHR_STATUS Tag Call      ${ehr_status_tag_body}
    Should Contain      ${err_msg}      422 != 200
    Should Be Equal     ${resp.json()['error']}     Unprocessable Entity
    [Teardown]      (admin) delete ehr

7. Create EHR_STATUS Tag With Invalid Target Path In Body
    [Tags]      Negative
    [Setup]     Precondition Create EHR With EHR_STATUS
    Create Session For EHR_STATUS Tag Calls
    &{ehr_status_tag_body}      Create Dictionary
    ...     key=${{str(uuid.uuid4())}}
    ...     value=${tag_value}
    ...     target_path=name/value
    ${err_msg}  Run Keyword And Expect Error    *
    ...     Create EHR_STATUS Tag Call      ${ehr_status_tag_body}
    Should Contain      ${err_msg}      422 != 200
    Should Be Equal     ${resp.json()['error']}     Unprocessable Entity
    Should Contain      ${resp.json()['message']}   target_path 'name/value' does not start at root
    [Teardown]      (admin) delete ehr


*** Keywords ***
Precondition Create EHR With EHR_STATUS
    prepare new request session    JSON
    ...     Prefer=return=representation
    create new EHR with ehr_status      ${VALID EHR DATA SETS}/000_ehr_status_with_other_details.json

Create Session For EHR_STATUS Tag Calls
    ${temp_str}     Remove String       ${BASEURL}      /rest/openehr/v1
    Set Suite Variable      ${EHR_STATUS_TAG_BASEURL}      ${temp_str}/rest/experimental/tags
    Create Session      SUT_TAG      ${EHR_STATUS_TAG_BASEURL}    headers=${headers}    verify=True

Set Tag Body In Array
    [Arguments]     ${custom_ehr_status_tag_body}=${NONE}
    IF      '''${custom_ehr_status_tag_body}''' != '''${NONE}'''
        @{tags_list}    Create List     ${custom_ehr_status_tag_body}
    ELSE
        Set Suite Variable    ${tag_key}    ${{str(uuid.uuid4())}}
        Set Suite Variable    ${tag_value}      EHR STATUS test value ${tag_key}[0:8]
        &{ehr_status_tag_body}      Create Dictionary
        ...     key=${tag_key}
        ...     value=${tag_value}
        ...     target_path=/name/value
        @{tags_list}    Create List     ${ehr_status_tag_body}
    END
    Set Test Variable   ${tags_list}      ${tags_list}

Default Checks For Tag Response
    Should Be Equal     ${tag_key}      ${firstRespArrEl['key']}
    Should Be Equal     ${ehr_id}       ${firstRespArrEl['owner_id']}
    ${ehrstatus_uid_value_temp}     Remove String   ${ehrstatus_uid_value}  ::${NODENAME}::1
    Should Be Equal     ${ehrstatus_uid_value_temp}      ${firstRespArrEl['target']}
    Should Be Equal     EHR_STATUS      ${firstRespArrEl['target_type']}
    Should Be Equal     ${tag_value}    ${firstRespArrEl['value']}
    Should Be Equal     /name/value     ${firstRespArrEl['target_path']}

Create EHR_STATUS Tag Call
    [Arguments]     ${custom_tag_body}=${NONE}
    Set Tag Body In Array       ${custom_tag_body}
    ${resp}     PUT On Session      SUT_TAG      /ehr/${ehr_id}/ehr_status/${ehrstatus_uid_value}/item_tag
    ...         json=${tags_list}    expected_status=anything
                Set Test Variable   ${resp}     ${resp}
                Status Should Be    200     ${resp}
                Set Test Variable       ${firstRespArrEl}       ${resp.json()[0]}
                Set Test Variable       ${EHR_STATUS_TAG_ID}    ${firstRespArrEl['id']}

Update EHR_STATUS Tag Call
    [Arguments]     ${custom_tag_body}
    Set Tag Body In Array       custom_ehr_status_tag_body=${custom_tag_body}
    ${resp}     PUT On Session      SUT_TAG      /ehr/${ehr_id}/ehr_status/${ehrstatus_uid_value}/item_tag
    ...         json=${tags_list}    expected_status=anything
                Set Test Variable   ${resp}     ${resp}
                Status Should Be    200     ${resp}
                Set Test Variable       ${firstRespArrEl}       ${resp.json()[0]}
                Set Test Variable       ${EHR_STATUS_TAG_ID}    ${firstRespArrEl['id']}

Get EHR_STATUS Tag Call
    ${resp}     GET On Session      SUT_TAG      /ehr/${ehr_id}/ehr_status/${ehrstatus_uid_value}/item_tag
    ...         expected_status=anything
                Set Test Variable   ${resp}     ${resp}
                Status Should Be    200     ${resp}

Delete EHR_STATUS Tag Call
    [Arguments]     ${ehr_status_ids_list}
    ${resp}     DELETE On Session      SUT_TAG      /ehr/${ehr_id}/ehr_status/${ehrstatus_uid_value}/item_tag
    ...         json=${ehr_status_ids_list}    expected_status=anything
                Set Test Variable   ${resp}     ${resp}
                Status Should Be    204     ${resp}