*** Settings ***
Documentation   Test suite to check Basic Composition Tags functionality.
...             \nCovers https://vitagroup-ag.atlassian.net/browse/CDR-1451
...             \nCovers below operations on Composition Tags:
...             - 1. Create Composition Tag - PUT /ehrbase/rest/experimental/tags/ehr/{ehr_id}/composition/{compo_status_uid}/item_tag
...             - 2. Get Composition Tag - GET /ehrbase/rest/experimental/tags/ehr/{ehr_id}/composition/{compo_status_uid}/item_tag
...             - 3. Update Composition Tag - PUT /ehrbase/rest/experimental/tags/ehr/{ehr_id}/composition/{compo_status_uid}/item_tag (with id in body)
...             - 4. Delete Composition Tag - DELETE /ehrbase/rest/experimental/tags/ehr/{ehr_id}/composition/{compo_status_uid}/item_tag

Resource        ${EXECDIR}/robot/_resources/suite_settings.robot
Resource        ${EXECDIR}/robot/_resources/keywords/ehr_keywords.robot
Resource        ${EXECDIR}/robot/_resources/keywords/composition_keywords.robot
Resource        ${EXECDIR}/robot/_resources/keywords/admin_keywords.robot
Suite Setup 		Set Library Search Order For Tests


*** Variables ***
${VALID EHR DATA SETS}       ${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/ehr/valid


*** Test Cases ***
1. Create Composition Tag
    #Expect 200 on Create Composition Tag
    [Tags]      Positive
    [Setup]     Precondition Upload OPT - Create EHR - Create Composition
    Create Session For Composition Tag Calls
    Create Composition Tag Call
    Set Suite Variable      ${COMPOSITION_TAG_ID_1}  ${COMPOSITION_TAG_ID}
    Default Checks For Tag Response

2. Retrieve EHR_STATUS Tag
    #Expect 200 on Retrieve Composition Tag
    [Tags]      Positive
    Get Composition Tag Call
    Set Test Variable       ${firstRespArrEl}       ${resp.json()[0]}
    Default Checks For Tag Response
    Create Composition Tag Call
    Set Suite Variable      ${COMPOSITION_TAG_ID_2}  ${COMPOSITION_TAG_ID}
    Get Composition Tag Call
    Length Should Be    ${resp.json()}    2

3. Update EHR_STATUS Tag
    #Expect 200 on Update Composition Tag
    [Tags]      Positive
    Set Test Variable   ${tag_key}      2222222222
    Set Test Variable   ${tag_value}    Composition test value modified
    &{composition_tag_body}      Create Dictionary
    ...     key=${tag_key}
    ...     value=${tag_value}
    ...     target_path=/name/value/temp
    ...     id=${COMPOSITION_TAG_ID_2}
    Update Composition Tag Call      custom_tag_body=${composition_tag_body}
    Should Be Equal     ${firstRespArrEl['id']}     ${COMPOSITION_TAG_ID_2}
    Should Be Equal     ${firstRespArrEl['target_path']}    /name/value/temp
    Should Be Equal     ${firstRespArrEl['key']}    ${tag_key}
    Should Be Equal     ${firstRespArrEl['value']}  ${tag_value}
    Get Composition Tag Call
    Length Should Be    ${resp.json()}    2

4. Delete Composition Tag
    #Expect 204 on Delete Composition Tag
    [Tags]      Positive
    @{tags_ids_list}    Create List     ${COMPOSITION_TAG_ID_1}      ${COMPOSITION_TAG_ID_2}
    Delete Composition Tag Call      composition_ids_list=${tags_ids_list}
    Get Composition Tag Call
    Should Be True      ${resp.content}     ${EMPTY}
    [Teardown]      (admin) delete ehr

5. Delete EHR Without Deleting Composition Tag
    # Delete EHR without deleting Composition Tag should pass and return 204.
    [Tags]      Negative
    [Setup]     Precondition Upload OPT - Create EHR - Create Composition
    Create Session For Composition Tag Calls
    Create Composition Tag Call
    Set Suite Variable      ${COMPOSITION_TAG_ID_TEMP}      ${COMPOSITION_TAG_ID}
    @{tags_ids_list}    Create List     ${COMPOSITION_TAG_ID_TEMP}
    (admin) delete ehr
    ${err_msg}  Run Keyword And Expect Error    *
    ...     Delete Composition Tag Call      ${tags_ids_list}
    Should Contain      ${err_msg}      404 != 204

6. Create Composition Tag Without Key In Body
    # Create Composition Tag without "key" in JSON body and expect 422 Unprocessable Entity as "key" is mandatory.
    [Tags]      Negative
    [Setup]     Precondition Upload OPT - Create EHR - Create Composition
    Create Session For Composition Tag Calls
    &{composition_tag_body}      Create Dictionary
    ...     value=${tag_value}
    ...     target_path=/name/value/temp
    ${err_msg}  Run Keyword And Expect Error    *
    ...     Create Composition Tag Call      ${composition_tag_body}
    Should Contain      ${err_msg}      422 != 200
    Should Be Equal     ${resp.json()['error']}     Unprocessable Entity
    [Teardown]      (admin) delete ehr

7. Delete Composition Tag Through Delete EHR_STATUS Tag
    # Needs analysis as Delete Composition Tag should not be done through Delete EHR_STATUS Tag endpoint.
    [Tags]      Negative    not-ready
    [Setup]     Precondition Upload OPT - Create EHR - Create Composition
    Create Session For Composition Tag Calls
    Create Composition Tag Call
    Get Composition Tag Call
    Length Should Be    ${resp.json()}    1
    Set Test Variable   ${ehrstatus_uid_value}      ${compo_uid_value}
    @{tags_ids_list}    Create List     ${COMPOSITION_TAG_ID}
    Delete EHR_STATUS Tag Call      ehr_status_ids_list=${tags_ids_list}
    Get Composition Tag Call
    Length Should Be    ${resp.json()}    1
    [Teardown]      (admin) delete ehr



*** Keywords ***
Precondition Upload OPT - Create EHR - Create Composition
    Upload OPT    nested/nested.opt
    prepare new request session    JSON
    ...     Prefer=return=representation
    create new EHR with ehr_status      ${VALID EHR DATA SETS}/000_ehr_status_with_other_details.json
    commit composition   format=CANONICAL_JSON
    ...                  composition=nested.en.v1__full_without_links.json
    Set Suite Variable      ${compo_uid_value}      ${response.json()['uid']['value']}

Create Session For Composition Tag Calls
    ${temp_str}     Remove String       ${BASEURL}      /rest/openehr/v1
    Set Suite Variable      ${COMPOSITION_TAG_BASEURL}      ${temp_str}/rest/experimental/tags
    Create Session      SUT_TAG      ${COMPOSITION_TAG_BASEURL}    headers=${headers}    verify=True

Set Tag Body In Array
    [Arguments]     ${custom_composition_tag_body}=${NONE}
    IF      '''${custom_composition_tag_body}''' != '''${NONE}'''
        @{tags_list}    Create List     ${custom_composition_tag_body}
    ELSE
        Set Suite Variable    ${tag_key}    ${{str(uuid.uuid4())}}
        Set Suite Variable    ${tag_value}      Composition test value ${tag_key}[0:8]
        &{composition_tag_body}      Create Dictionary
        ...     key=${tag_key}
        ...     value=${tag_value}
        ...     target_path=/name/value
        @{tags_list}    Create List     ${composition_tag_body}
    END
    Set Test Variable   ${tags_list}      ${tags_list}

Default Checks For Tag Response
    Should Be Equal     ${tag_key}      ${firstRespArrEl['key']}
    Should Be Equal     ${ehr_id}       ${firstRespArrEl['owner_id']}
    ${compo_uid_value_temp}     Remove String   ${compo_uid_value}  ::${NODENAME}::1
    Should Be Equal     ${compo_uid_value_temp}      ${firstRespArrEl['target']}
    Should Be Equal     COMPOSITION      ${firstRespArrEl['target_type']}
    Should Be Equal     ${tag_value}    ${firstRespArrEl['value']}
    Should Be Equal     /name/value     ${firstRespArrEl['target_path']}

Create Composition Tag Call
    [Arguments]     ${custom_tag_body}=${NONE}
    Set Tag Body In Array       ${custom_tag_body}
    ${resp}     PUT On Session      SUT_TAG      /ehr/${ehr_id}/composition/${compo_uid_value}/item_tag
    ...         json=${tags_list}    expected_status=anything
                Set Test Variable   ${resp}     ${resp}
                Status Should Be    200     ${resp}
                Set Test Variable       ${firstRespArrEl}       ${resp.json()[0]}
                Set Test Variable       ${COMPOSITION_TAG_ID}    ${firstRespArrEl['id']}

Get Composition Tag Call
    ${resp}     GET On Session      SUT_TAG      /ehr/${ehr_id}/composition/${compo_uid_value}/item_tag
    ...         expected_status=anything
                Set Test Variable   ${resp}     ${resp}
                Status Should Be    200     ${resp}

Update Composition Tag Call
    [Arguments]     ${custom_tag_body}
    Set Tag Body In Array       custom_composition_tag_body=${custom_tag_body}
    ${resp}     PUT On Session      SUT_TAG      /ehr/${ehr_id}/composition/${compo_uid_value}/item_tag
    ...         json=${tags_list}    expected_status=anything
                Set Test Variable   ${resp}     ${resp}
                Status Should Be    200     ${resp}
                Set Test Variable       ${firstRespArrEl}       ${resp.json()[0]}
                Set Test Variable       ${COMPOSITION_TAG_ID}   ${firstRespArrEl['id']}

Delete Composition Tag Call
    [Arguments]     ${composition_ids_list}
    ${resp}     DELETE On Session      SUT_TAG      /ehr/${ehr_id}/composition/${compo_uid_value}/item_tag
    ...         json=${composition_ids_list}    expected_status=anything
                Set Test Variable   ${resp}     ${resp}
                Status Should Be    204     ${resp}

Delete EHR_STATUS Tag Call
    [Arguments]     ${ehr_status_ids_list}
    ${resp}     DELETE On Session      SUT_TAG      /ehr/${ehr_id}/ehr_status/${ehrstatus_uid_value}/item_tag
    ...         json=${ehr_status_ids_list}    expected_status=anything
                Set Test Variable   ${resp}     ${resp}
                Status Should Be    204     ${resp}