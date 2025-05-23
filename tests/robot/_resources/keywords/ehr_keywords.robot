# Copyright (c) 2019 Wladislaw Wagner (Vitasystems GmbH), Pablo Pazos (Hannover Medical School).
#
# This file is part of Project EHRbase
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.



*** Settings ***
Documentation   EHR Keywords
Resource        ../suite_settings.robot



*** Variables ***
${VALID EHR DATA SETS}       ${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/ehr/valid
${INVALID EHR DATA SETS}     ${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/ehr/invalid


*** Keywords ***
# 1) High Level Keywords

update EHR: set ehr_status is_queryable
    [Arguments]         ${value}    ${multitenancy_token}=${None}
    [Documentation]     valid values: ${TRUE}, ${FALSE}
    ...                 default: ${TRUE}

    # from preceding request of `create new EHR ...`
    extract ehr_id from response (JSON)
    extract system_id from response (JSON)
    extract ehrstatus_uid (JSON)
    extract ehr_status from response (JSON)

    set is_queryable / is_modifiable    is_queryable=${value}

    set ehr_status of EHR       multitenancy_token=${multitenancy_token}


update EHR: set ehr-status modifiable
    [Arguments]         ${value}
    [Documentation]     valid values: ${TRUE}, ${FALSE}
    ...                 default: ${TRUE}

    # from preceding request of `create new EHR ...`
    extract ehr_id from response (JSON)
    extract system_id from response (JSON)
    extract subject_id from response (JSON)
    extract ehrstatus_uid (JSON)
    extract ehr_status from response (JSON)

    set is_queryable / is_modifiable    is_modifiable=${value}

    set ehr_status of EHR


check response of 'update EHR' (JSON)
    Status Should Be    200
    ${ehrstatus_uid}    Set Variable    ${response.json()['uid']['value']}
    @{split_ehrstatus_uid}      Split String    ${ehrstatus_uid}    ::
    Should Be Equal     ${split_ehrstatus_uid}[2]   2

    # TODO: @WLAD check Github Issue #272
    # String    response body subject external_ref id value    ${subject_Id}
    Should Be Equal As Strings      ${response.json()['_type']}     EHR_STATUS


# 2) HTTP Methods
#    POST
#    PUT
#    GET
#    DELETE
#
# 3) HTTP Headers
#
# 4) FAKE Data



create new EHR
    [Documentation]     Creates new EHR record with a server-generated ehr_id.
    ...                 DEPENDENCY: `prepare new request session`
    [Arguments]         ${ehrScape}=False   ${multitenancy_token}=${None}

    IF  '${multitenancy_token}' != '${None}'
        Set To Dictionary     ${headers}    Authorization=Bearer ${multitenancy_token}
    END
    IF      '${ehrScape}' == 'False'
        ${resp}     POST On Session     ${SUT}    /ehr
                    ...     expected_status=anything        headers=${headers}
                    Status Should Be    201    ${resp}
                    Set Suite Variable  ${resp}     ${resp}

                    extract ehr_id from response (JSON)
                    extract system_id from response (JSON)
                    # TODO: @WLAD check Github Issue #272
                    # extract subject_id from response (JSON)
                    extract ehr_status from response (JSON)
                    extract ehrstatus_uid (JSON)

                    Set Suite Variable    ${response}    ${resp}
    ELSE
        &{prms}=            Create Dictionary   subjectId=74777-1259
                            ...                 subjectNamespace=testIssuer
                            #...                 modifiable=true
                            #...                 queryable=true
                            #...                 otherDetails=not provided

        ${resp}=            POST On Session     ${SUT}   ${ECISURL}/ehr   params=&{prms}    headers=${headers}
                            Status Should Be    201
                            Set Suite Variable  ${resp}     ${resp}

                            extract ehr_id from response (JSON)
                            extract system_id from response (JSON)

                            extract ehr_status from response (JSON)
                            extract ehrstatus_uid (JSON)

                            Set Suite Variable    ${response}    ${resp}

                            #Output Debug Info To Console  # NOTE: won't work with content-type=XML
    END

Create Session For EHR With Headers For Multitenancy With Bearer Token
    [Arguments]     ${encodedToken}
    Delete All Sessions
    &{additionalHeaders}    Create Dictionary
    ...            Authorization=Bearer ${encodedToken}
    &{headersEhrMultitenancy}          Create Dictionary     &{EMPTY}
                        Set To Dictionary   ${headersEhrMultitenancy}
                        ...                 Content-Type=application/json
                        ...                 Accept=application/json
                        ...                 Prefer=return=representation
                        ...                 &{additionalHeaders}
    Create Session      ${SUT}    ${BASEURL}    debug=2
                        ...                 headers=${headersEhrMultitenancy}    verify=True
                        Set Test Variable   ${headers}    &{headersEhrMultitenancy}

Create New EHR With Multitenant Token
    [Documentation]     Creates new EHR record with a server-generated ehr_id and multitenant token.
    ...     Takes 1 argument, encodedToken (mandatory).
    ...     EHR will be created with Authorization=Bearer {encodedToken} in headers.
    [Arguments]     ${encodedToken}
    Create Session For EHR With Headers For Multitenancy With Bearer Token      ${encodedToken}
    ${resp}             POST on session     ${SUT}    /ehr
    ...         expected_status=anything        headers=${headers}
    Should Be Equal As Strings      ${resp.status_code}     201
    ${ehrstatus_uid}    Set Variable        ${resp.json()['ehr_status']['uid']['value']}
    @{split_ehrstatus_uid}      Split String    ${ehrstatus_uid}    ::
    ${short_uid}        Set Variable        ${split_ehrstatus_uid}[0]
    Set Suite Variable    ${ehr_id}         ${resp.json()['ehr_id']['value']}
    Set Suite Variable    ${system_id}      ${resp.json()['system_id']['value']}
    Set Suite Variable    ${ehr_status}     ${resp.json()['ehr_status']}
    Set Suite Variable    ${versioned_status_uid}       ${short_uid}
    Set Suite Variable    ${response}       ${resp}
    Set Test Variable     ${ehrstatus_uid}  ${ehrstatus_uid}
    Log     ${ehr_id}
    Log     ${system_id}
    Log     ${ehr_status}
    Log     ${versioned_status_uid}

Create EHR With Subject External Ref With Multitenant Token
    [Arguments]     ${encodedToken}     ${ehr_status_obj}=${VALID EHR DATA SETS}/000_ehr_status_with_other_details.json
    Create Session For EHR With Headers For Multitenancy With Bearer Token      ${encodedToken}
    ${ehr_status_json}  Load JSON From File    ${ehr_status_obj}
    ${ehr_status_json}     Update Value To Json     ${ehr_status_json}    $.subject.external_ref.id.value
                                    ...    ${{str(uuid.uuid4())}}
    ${ehr_status_json}     Update Value To Json    ${ehr_status_json}     $.subject.external_ref.namespace
                        ...    namespace_${{''.join(random.choices(string.digits, k=7))}}
    ${resp}             POST on session     ${SUT}    /ehr      json=${ehr_status_json}
    ...         expected_status=anything        headers=${headers}
    Should Be Equal As Strings      ${resp.status_code}     201
    ${ehrstatus_uid}    Set Variable        ${resp.json()['ehr_status']['uid']['value']}
    ${short_uid}        Remove String       ${ehrstatus_uid}    ::${CREATING_SYSTEM_ID}::1
    Set Suite Variable    ${ehr_id}         ${resp.json()['ehr_id']['value']}
    Set Suite Variable    ${system_id}      ${resp.json()['system_id']['value']}
    Set Suite Variable    ${ehr_status}     ${resp.json()['ehr_status']}
    Set Suite Variable    ${ehrstatus_uid}     ${ehrstatus_uid}
    Set Suite Variable    ${versioned_status_uid}       ${short_uid}
    Set Suite Variable    ${subject_external_ref_value}     ${resp.json()['ehr_status']['subject']['external_ref']['id']['value']}
    Set Suite Variable    ${response}       ${resp}
    Log     ${ehr_id}
    Log     ${system_id}
    Log     ${ehr_status}
    Log     ${versioned_status_uid}

#TODO: @WLAD  rename KW name when refactor this resource file
create supernew ehr
    [Documentation]     Creates new EHR record with a server-generated ehr_id.
    ...                 DEPENDENCY: `prepare new request session`

    ${resp}             POST On Session     ${SUT}      /ehr
                        ...     expected_status=anything    headers=${headers}
                        Set Test Variable    ${response}    ${resp}
                        #Output Debug Info To Console


create new EHR (XML)
    [Documentation]     Creates new EHR record with a server-generated ehr_id.
    ...                 DEPENDENCY: `prepare new request session`

    ${resp}     POST On Session     ${SUT}    /ehr
                ...     expected_status=anything        headers=${headers}

                Status Should Be    201

                Set Test Variable    ${response}    ${resp}

                extract ehr_id from response (XML)
                extract system_id from response (XML)
                extract ehrstatus_uid (XML)







# ooooooooo.   oooooooooooo  .oooooo..o ooooooooo.     .oooooo.   ooooo      ooo  .oooooo..o oooooooooooo  .oooooo..o
# `888   `Y88. `888'     `8 d8P'    `Y8 `888   `Y88.  d8P'  `Y8b  `888b.     `8' d8P'    `Y8 `888'     `8 d8P'    `Y8
#  888   .d88'  888         Y88bo.       888   .d88' 888      888  8 `88b.    8  Y88bo.       888         Y88bo.
#  888ooo88P'   888oooo8     `"Y8888o.   888ooo88P'  888      888  8   `88b.  8   `"Y8888o.   888oooo8     `"Y8888o.
#  888`88b.     888    "         `"Y88b  888         888      888  8     `88b.8       `"Y88b  888    "         `"Y88b
#  888  `88b.   888       o oo     .d8P  888         `88b    d88'  8       `888  oo     .d8P  888       o oo     .d8P
# o888o  o888o o888ooooood8 8""88888P'  o888o         `Y8bood8P'  o8o        `8  8""88888P'  o888ooooood8 8""88888P'
#
# [ RESPONSE VALIDATION ]

# POST POST POST POST
#/////////////////////

validate POST response - 201 created ehr
    [Documentation]     CASE: new ehr was created.
    ...                 Request was send with `Prefer=return=representation`.

    Status Should Be    201
    Log     ${response.json()}
    #Object              response body


validate POST response - 204 no content
    [Documentation]     Old keyword. To be removed if not used by tests.
    ...                 CASE: new ehr was created.
    ...                 Request was send w/o `Prefer=return` header or with
    ...                 `Prefer=return=minimal`. Body has to be empty.

    Status Should Be    204
    Should Be Equal As Strings     ${response.content}     ${EMPTY}

validate POST response - 201 no content
    [Documentation]     CASE: new ehr was created.
    ...                 Request was send w/o `Prefer=return` header or with
    ...                 `Prefer=return=minimal`. Body has to be empty.

    Status Should Be    201
    Should Be Equal As Strings     ${response.content}     ${EMPTY}

# PUT PUT PUT PUT PUT
#/////////////////////

validate PUT response - 204 no content
    [Documentation]     CASE: new ehr was created w/ given ehr_id.
    ...                 Request was send w/o `Prefer=return` header or with
    ...                 `Prefer=return=minimal`. Body has to be empty.

    Status Should Be    204
    Should Be Equal As Strings     ${response.content}     ${EMPTY}





# create EHR XML
#     [Documentation]     Creates new EHR record and extracts server generated ehr_id
#     ...                 Puts `ehr_id` on Test Level scope so that it can be accessed
#     ...                 by other keywords, e.g. `commit composition (XML)`.

#     Log         DEPRECATION WARNING: @WLAD remove this KW - it's only used in old AQL-QUERY tests.
#                 ...         level=WARN

#     &{headers}=         Create Dictionary  Prefer=return=representation  Accept=application/xml
#     ${resp}=            Post Request       ${SUT}     /ehr    headers=${headers}
#                         Should Be Equal As Strings    ${resp.status_code}    201

#     ${xresp}=           Parse Xml          ${resp.text}
#                         Log Element        ${xresp}
#                         Set Test Variable  ${xresp}   ${xresp}

#     ${xehr_id}=         Get Element        ${xresp}    ehr_id/value
#                         Set Test Variable  ${ehr_id}   ${xehr_id.text}
#                         # Log To Console     ${ehr_id}


create new EHR with ehr_status
    [Arguments]         ${ehr_status_object}
    [Documentation]     Creates new EHR record with a server-generated ehr_id.
    ...                 DEPENDENCY: `prepare new request session`
    ...                 :ehr_status_object: ehr_status_as_json_file

    ${ehr_status_json}  Load JSON From File    ${ehr_status_object}
    ${ehr_status_json}  Update Value To Json    ${ehr_status_json}    $.subject.external_ref.id.value
                        ...    ${{str(uuid.uuid4())}}

    ${ehr_status_json}  Update Value To Json    ${ehr_status_json}    $.subject.external_ref.namespace
                        ...    namespace_${{''.join(random.choices(string.digits, k=7))}}

    Create Session      ${SUT}    ${BASEURL}    debug=2
                        ...     verify=False    #auth=${CREDENTIALS}

    ${resp}             POST On Session     ${SUT}      /ehr    json=${ehr_status_json}
                        ...     expected_status=anything    headers=${headers}
						Set Suite Variable    ${resp}    	${resp}
                        Set Suite Variable    ${response}	${resp}
                        Status Should Be    201
                        Set Suite Variable      ${ehr_id_obj}       ${resp.json()['ehr_id']}
                        Set Suite Variable      ${ehr_id_value}     ${resp.json()['ehr_id']['value']}
                        Set Suite Variable      ${ehrstatus_uid_value}      ${resp.json()['ehr_status']['uid']['value']}
                        Set Suite Variable      ${ehrstatus_uid}    ${ehrstatus_uid_value}
                        Set Suite Variable      ${ehr_status_subject_external_ref_value}
                        ...     ${resp.json()['ehr_status']['subject']['external_ref']['id']['value']}
                        Set Suite Variable      ${subject_external_ref_value}
                        ...     ${ehr_status_subject_external_ref_value}
                        Set Suite Variable      ${ehr_id}       ${ehr_id_value}

Create EHR With Subject External Ref
    [Documentation]     Create EHR with EHR_Status and other details, so it can contain correct subject object.
    prepare new request session     headers=JSON    Prefer=return=representation
    create new EHR with ehr_status  ${VALID EHR DATA SETS}/000_ehr_status_with_other_details.json

create new EHR by ID
    [Arguments]         ${ehr_id}   ${ehr_status_json}=${NONE}
    [Documentation]     Create a new EHR with the specified EHR identifier.
    ...                 DEPENDENCY: `prepare new request session`

    IF      """${ehr_status_json}""" != """${NONE}"""
        ${resp}     PUT On Session      ${SUT}      /ehr/${ehr_id}      json=${ehr_status_json}
                    ...     headers=${headers}      expected_status=anything
    ELSE
        ${resp}     PUT On Session      ${SUT}      /ehr/${ehr_id}
                    ...     headers=${headers}      expected_status=anything
    END
    Set Suite Variable    ${resp}    	${resp}
    Set Suite Variable    ${response}	${resp}


create new EHR for subject_id (JSON)
    [Arguments]         ${subject_id}
    ${ehr_status_json}  Load JSON From File   ${VALID EHR DATA SETS}/000_ehr_status.json
    ${ehr_status_json}  Update Value To Json  ${ehr_status_json}   $.subject.external_ref.id.value
                        ...     ${subject_id}

    ${resp}             POST On Session     ${SUT}      /ehr    json=${ehr_status_json}
                        ...     expected_status=anything    headers=${headers}
                        Set Suite Variable    ${response}    ${resp}


create new EHR with subject_id (JSON)

                        generate random subject_id
    ${ehr_status_json}  Load JSON From File   ${VALID EHR DATA SETS}/000_ehr_status.json
    ${ehr_status_json}      Update Value To Json    ${ehr_status_json}      $.subject.external_ref.id.value
                            ...     ${subject_id}

    ${resp}             POST On Session     ${SUT}      /ehr    json=${ehr_status_json}
                        ...     expected_status=anything    headers=${headers}
                        Set Suite Variable    ${resp}    	${resp}
						Set Suite Variable    ${response}	${resp}

                        extract ehr_id from response (JSON)
                        extract system_id from response (JSON)
                        extract ehr_status from response (JSON)













create new EHR can't be modified

    prepare new request session   Prefer=return=representation
    generate random subject_id

    ${ehr_status_json}  Load JSON From File   ${VALID EHR DATA SETS}/ehr_can_not_be_modifyable.json
    ${ehr_status_json}  Update Value To Json  ${ehr_status_json}   $.subject.external_ref.id.value
                        ...     ${subject_id}

    ${resp}     POST On Session     ${SUT}    /ehr      json=${ehr_status_json}
                ...     expected_status=anything        headers=${headers}
                Set Suite Variable    ${response}    ${resp}
                extract ehr_id from response (JSON)


check content of created EHR (JSON)
                Status Should Be    201
                Should Be Equal As Strings      ${response.json()['ehr_id']['value']}       ${ehr_id}
                Should Be Equal As Strings      ${response.json()['system_id']['value']}    ${system_id}

                # TODO: @WLAD check Github issue #272
                # String    response body ehr_status subject external_ref id value    ${subject_Id}

                Should Be Equal     ${response.json()['ehr_status']}      ${ehr_status}

                # extract ehr_id from response (JSON)
                # extract system_id from response (JSON)
                # extract subject_id from response (JSON)    # is in ehr_status
                # extract ehr_status from response (JSON)


retrieve EHR by ehr_id
    [Documentation]     Retrieves EHR with specified ehr_id.
    ...                 DEPENDENCY: `prepare new request session` and keywords that
    ...                             create and expose an `ehr_id` e.g.
    ...                             - `create new EHR`

    ${resp}=            GET On Session      ${SUT}      /ehr/${ehr_id}
                        ...         expected_status=anything        headers=${headers}
                        Status Should Be    200

Retrieve EHR By Ehr_id With Multitenant Token
    [Arguments]     ${expected_code}=200    ${multitenancy_token}=${None}
    &{headers}      Create Dictionary
    IF  '${multitenancy_token}' != '${None}'
        Set To Dictionary     ${headers}    Authorization=Bearer ${multitenancy_token}
    END
    ${resp}     GET on session     ${SUT}    /ehr/${ehr_id}
    ...         expected_status=anything        headers=${headers}
    Set Suite Variable    ${response}       ${resp}
    Set Suite Variable    ${statusCode}     ${resp.status_code}
    Should Be Equal As Strings      ${resp.status_code}     ${expected_code}

Retrieve EHR By Ehr Id (ECIS)
    [Documentation]     Retrieves EHR with specified ehr_id (ECIS endpoint).
    ...                 DEPENDENCY: `prepare new request session` and keywords that
    ...                             create and expose an `ehr_id` e.g.
    ...                             - `create new EHR`
    Create Session      ${SUT}    ${ECISURL}    debug=2
                        ...     verify=True
    &{headers}      Create Dictionary       Accept=application/json
    ${resp}     GET on session     ${SUT}    /ehr/${ehr_id}
                ...     expected_status=anything        headers=${headers}
                Status Should Be    200
                Set Test Variable       ${resp}         ${resp}
                Set Test Variable       ${response}     ${resp}

retrieve EHR by subject_id
    [Documentation]     Retrieves EHR with specified subject_id and namespace.
    ...                 DEPENDENCY: `prepare new request session` and keywords that
    ...                             create and expose an `subject_id` e.g.
    ...                             - `create new EHR`
    ...                             - `generate random subject_id`
    [Arguments]         ${subject_namespace}=patients
    &{prms}=            Create Dictionary   subject_id=${subject_id}
                        ...     subject_namespace=${subject_namespace}

    ${resp}=            GET On Session      ${SUT}      /ehr    params=${prms}
                        ...     expected_status=anything        headers=${headers}
                        Status Should Be    200

Retrieve EHR By Subject Id And Subject Namespace (ECIS)
    [Documentation]     Retrieves EHR with specified subject_id and namespace.
    ...                 DEPENDENCY: `prepare new request session` and keywords that
    ...                             create and expose an `subject_id` e.g.
    ...                             - `create new EHR`
    ...                             - `generate random subject_id`
    [Arguments]         ${subject_id}=74777-1259      ${subject_namespace}=testIssuer
    Create Session      ${SUT}    ${ECISURL}    debug=2
                        ...     verify=True
    &{headers}      Create Dictionary       Accept=application/json
    &{prms}         Create Dictionary       subjectId=${subject_id}     subjectNamespace=${subject_namespace}
    ${resp}         GET on session      ${SUT}      /ehr/${ehr_id}     params=${prms}
                    ...     expected_status=anything        headers=${headers}
                    Status Should Be    200
                    Set Test Variable       ${resp}         ${resp}
                    Set Test Variable       ${response}     ${resp}

check content of retrieved EHR (JSON)

    Status Should Be    200

    # NOTE: RESTInstace provides a nice way to verify results

    #         |<---    actual data                 --->|<--- expected data --->|
    Should Be Equal As Strings      ${response.json()['ehr_id']['value']}       ${ehr_id}
    Should Be Equal As Strings      ${response.json()['system_id']['value']}    ${system_id}

    # TODO: @Wlad check Github Issue #272
    # String    response body ehr_status subject external_ref id value    ${subject_Id}

    Should Be Equal      ${response.json()['ehr_status']}    ${ehr_status}
    #Object    response body ehr_status                      ${ehr_status}
    # Boolean   response body ehr_status is_queryable         ${TRUE}           # is already checked
    # Boolean   response body ehr_status is_modifiable        ${TRUE}           # in ehr_status


    # It's not required to put actuals into variables and apply verification keywords
    # --- actual data ---|                                     # --- expected data ---|
    ${actual_ehrid}=        Set Variable      ${response.json()['ehr_id']['value']}
    ${actual_ehrstatus}=    Set Variable      ${response.json()['ehr_status']}

                        # Output    ${actual_ehrid}[0]
                        # Output    ${ehr_id}
                        # Output    ${actual_ehrstatus}[0]
                        # Output    ${ehr_status}

                        # Should Be Equal    ${actual_ehrid}[0]    ${ehr_id}
                        # Should Be Equal    ${actual}[0]    ${ehr_status}

    # NOTE: this checks are not required any more
    # Should Be Equal As Strings   ${ehr_id}   ${resp.json()['ehr_id']['value']}
    # Should Be Equal As Strings   ${is_queryable}   ${resp.json()['ehr_status']['is_queryable']}
    # Should Be Equal As Strings   ${is_modifiable}   ${resp.json()['ehr_status']['is_modifiable']}
    # Should Be Equal As Strings   ${subject_id}   ${resp.json()['ehr_status']['subject']['external_ref']['id']['value']}




retrieve non-existing EHR by ehr_id
    ${resp}=            GET On Session      ${SUT}      /ehr/${ehr_id}
                        ...         expected_status=anything        headers=${headers}
                        Status Should Be    404


retrieve non-existing EHR by subject_id
    &{prms}=            Create Dictionary   subject_id=${subject_id}
                        ...     subject_namespace=patients

    ${resp}=            GET On Session      ${SUT}      /ehr    params=&{prms}
                        ...     expected_status=anything        headers=${headers}
                        Status Should Be    404


get ehr_status of EHR
    [Documentation]     Gets status of EHR with given ehr_id.
    ...                 DEPENDENCY: `prepare new request session` and keywords that
    ...                             create and expose an `ehr_id` e.g.
    ...                             - `create new EHR`
    ...                             - `generate random ehr_id`
    [Arguments]     ${multitenancy_token}=${None}
    &{headers}      Create Dictionary   Accept=application/json
    IF  '${multitenancy_token}' != '${None}'
        Set To Dictionary     ${headers}    Authorization=Bearer ${multitenancy_token}
    END
    ${resp}=            GET On Session      ${SUT}      /ehr/${ehr_id}/ehr_status
                        ...     expected_status=anything        headers=${headers}
                        Set Test Variable    ${response}    ${resp}


# get ehr_status of EHR with version at time
#     [Arguments]         ${version_at_time}
#     [Documentation]     Gets status of EHR with given `ehr_id` and `version at time`.
#     ...                 DEPENDENCY: `prepare new request session` and keywords that
#     ...                             create and expose an `ehr_id` e.g.
#     ...                             - `create new EHR`
#     ...                             - `generate random ehr_id`
#
#     &{resp}=            REST.GET    ${baseurl}/ehr/${ehr_id}/ehr_status?version_at_time=${version_at_time}
#                         Set Test Variable    ${response}    ${resp}
#
#                         # Output Debug Info To Console


get ehr_status of fake EHR
    [Documentation]     Gets status of EHR with given ehr_id.
    ...                 DEPENDENCY: `prepare new request session` and keywords that
    ...                             create and expose an `ehr_id` e.g.
    ...                             - `create new EHR`
    ...                             - `generate random ehr_id`
    Set To Dictionary       ${headers}      Content-Type=application/json
    ${resp}=            GET On Session      ${SUT}      /ehr/${ehr_id}/ehr_status
                        ...     expected_status=anything        headers=${headers}
                        Set Test Variable    ${response}    ${resp}

                        Status Should Be    404


get versioned ehr_status of EHR
    [Documentation]     Gets versioned status of EHR with given ehr_id.
    ...                 DEPENDENCY: `prepare new request session` and keywords that
    ...                             create and expose an `ehr_id` e.g.
    ...                             - `create new EHR`
    ...                             - `generate random ehr_id`
    [Arguments]     ${default_headers}=default      ${multitenancy_token}=${None}
    ${headers_variable_exists}      Run Keyword And Return Status
    ...     Variable Should Exist    ${headers}
    IF     ${headers_variable_exists} == ${FALSE}
        &{headers}      Create Dictionary
    END
    IF      '${default_headers}' == 'default'
        &{headers}      Create Dictionary       Content-Type=application/json
    END
    IF  '${multitenancy_token}' != '${None}'
        Set To Dictionary   ${headers}      Authorization=Bearer ${multitenancy_token}
    END

    ${resp}=        GET On Session      ${SUT}      /ehr/${ehr_id}/versioned_ehr_status
                    ...     expected_status=anything        headers=${headers}
                    Set Test Variable    ${response}    ${resp}


get revision history of versioned ehr_status of EHR
    [Documentation]     Gets revision history of versioned status of EHR with given ehr_id.
    ...                 DEPENDENCY: `prepare new request session` and keywords that
    ...                             create and expose an `ehr_id` e.g.
    ...                             - `create new EHR`
    ...                             - `generate random ehr_id`
    [Arguments]     ${default_headers}=default      ${multitenancy_token}=${None}
    ${headers_variable_exists}      Run Keyword And Return Status
    ...     Variable Should Exist    ${headers}
    IF     ${headers_variable_exists} == ${FALSE}
        &{headers}      Create Dictionary
    END
    IF      '${default_headers}' == 'default'
        &{headers}      Create Dictionary       Content-Type=application/json
    END
    IF  '${multitenancy_token}' != '${None}'
        Set To Dictionary   ${headers}      Authorization=Bearer ${multitenancy_token}
    END

    ${resp}=        GET On Session      ${SUT}      /ehr/${ehr_id}/versioned_ehr_status/revision_history
                    ...     expected_status=anything        headers=${headers}
                    Set Test Variable    ${response}    ${resp}


get versioned ehr_status of EHR by time
    [Documentation]     Gets status of EHR with given ehr_id.
    ...                 DEPENDENCY: `prepare new request session` and keywords that
    ...                             create and expose an `ehr_id` e.g.
    ...                             - `create new EHR`
    ...                             - `generate random ehr_id`
    ...                 Input: `query` variable containing query parameters as object or directory (e.g. _limit=2 for [$URL]?_limit=2)
    # Trick to see if ${query} was set. (if not, "Get Variable Value" will set the value to None)
    ${query} = 	Get Variable Value 	${query}
    # Only run the GET with query if $query was set
    Run Keyword Unless 	$query is None 	internal get versioned ehr_status of EHR by time with query
    Run Keyword If 	$query is None 	internal get versioned ehr_status of EHR by time without query


# internal only, do not call from outside. use "get versioned ehr_status of EHR by time" instead
internal get versioned ehr_status of EHR by time with query
    #&{prms}       Create Dictionary   version_at_time=${query}
    Set To Dictionary       ${headers}      Content-Type=application/json
    ${resp}=        GET On Session      ${SUT}      /ehr/${ehr_id}/versioned_ehr_status/version     params=${query}
                    ...     expected_status=anything        headers=${headers}
                    Set Test Variable    ${response}    ${resp}


# internal only, do not call from outside. use "get versioned ehr_status of EHR by time" instead
internal get versioned ehr_status of EHR by time without query
    [Arguments]     ${default_headers}=default      ${multitenancy_token}=${None}
    ${headers_variable_exists}      Run Keyword And Return Status
    ...     Variable Should Exist    ${headers}
    IF     ${headers_variable_exists} == ${FALSE}
        &{headers}      Create Dictionary
    END
    IF      '${default_headers}' == 'default'
        &{headers}      Create Dictionary       Content-Type=application/json
    END
    IF  '${multitenancy_token}' != '${None}'
        Set To Dictionary   ${headers}      Authorization=Bearer ${multitenancy_token}
    END
    ${resp}=        GET On Session      ${SUT}      /ehr/${ehr_id}/versioned_ehr_status/version
                    ...     expected_status=anything        headers=${headers}
                    Set Test Variable    ${response}    ${resp}


get versioned ehr_status of EHR by version uid
    [Documentation]     Gets revision history of versioned status of EHR with given ehr_id.
    ...                 DEPENDENCY: `prepare new request session` and keywords that
    ...                             create and expose an `ehr_id` e.g.
    ...                             - `create new EHR`
    ...                             - `generate random ehr_id`
    ...                 Input: `version_uid` variable needs to be set
    Set To Dictionary   ${headers}      Content-Type=application/json
    ${resp}=        GET On Session      ${SUT}      /ehr/${ehr_id}/versioned_ehr_status/version/${version_uid}
                    ...     expected_status=anything        headers=${headers}
                    Set Test Variable    ${response}    ${resp}

Update EHR Status (ECIS)
    [Documentation]     Sets status of EHR with given `ehr_id` (ECIS endpoint).
    [Arguments]     ${ehr_id}       ${ehr_status_body}
    &{headers}      Create Dictionary   Content-Type=application/json   Accept=application/json
    Create Session      ${SUT}    ${ECISURL}    debug=2
                        ...     verify=True
    ${resp}         PUT On Session      ${SUT}      /ehr/${ehr_id}/status      json=${ehr_status_body}
                    ...     expected_status=anything        headers=${headers}
                    Status Should Be    200
                    Set Test Variable       ${resp}         ${resp}
                    Set Test Variable       ${response}     ${resp}

set ehr_status of EHR
    [Documentation]     Sets status of EHR with given `ehr_id`.
    ...                 DEPENDENCY: `prepare new request session` and keywords that
    ...                             create and expose an `ehr_status` as JSON
    ...                             object e.g. `extract ehr_status from response (JSON)`
    [Arguments]     ${multitenancy_token}=${None}
    &{headers}      Create Dictionary
    ...     Accept=application/json     Content-Type=application/json
    ...     Prefer=return=representation    If-Match=${ehrstatus_uid}
    IF  '${multitenancy_token}' != '${None}'
        Set To Dictionary      ${headers}       Authorization=Bearer ${multitenancy_token}
    END
    ${resp}         PUT On Session     ${SUT}    /ehr/${ehr_id}/ehr_status    json=${ehr_status}
                    ...     headers=${headers}      expected_status=anything
                    Set Test Variable    ${response}    ${resp}
                    Status Should Be    200

update ehr_status of fake EHR (w/o body)
    Set To Dictionary       ${headers}       Content-Type=application/json   Prefer=return=representation
                            ...        If-Match=${ehr_id}
    ${resp}         PUT On Session     ${SUT}    /ehr/${ehr_id}/ehr_status
                    ...     headers=${headers}      expected_status=anything
                    # TODO: spec --> "If-Match: {preceding_version_uid}"
                    Set Test Variable    ${response}    ${resp}                 #       update If-Match value asap

                    Status Should Be    404
                    Should Be Equal As Strings      ${response.json()["error"]}     EHR with this ID not found


update ehr_status of fake EHR (with body)

    generate fake ehr_status
    Set To Dictionary       ${headers}       Content-Type=application/json   Prefer=return=representation
                            ...        If-Match=${ehr_id}::${NODENAME}::1
    ${resp}         PUT On Session     ${SUT}    /ehr/${ehr_id}/ehr_status      json=${ehr_status}
                    ...     headers=${headers}      expected_status=anything
                    # NOTE: spec --> "If-Match: {preceding_version_uid}"
                    Set Test Variable    ${response}    ${resp}

                    Status Should Be    404
                    # String    response body error    EHR with this ID not found


extract ehr_id from response (JSON)
    [Documentation]     Extracts ehr_id from response of preceding request.
    ...                 DEPENDENCY: `create new EHR`
    [Arguments]     ${ehrScape}=false
    IF      '${ehrScape}' != 'false'
        ${ehrId}        Collections.Get From Dictionary     ${response.json()}      ehrId
                        Set Suite Variable    ${ehr_id}     ${ehrId}
                        Log To Console    \n\tDEBUG OUTPUT - EHR_ID: \n\t${ehr_id}
                        Return From Keyword
    ELSE
        Set Suite Variable      ${ehr_id}       ${resp.json()['ehr_id']['value']}
    END


extract system_id from response (JSON)
    [Documentation]     Extracts `system_id` from response of preceding request.
    ...                 DEPENDENCY: `create new EHR`
    [Arguments]     ${ehrScape}=false
    IF      '${ehrScape}' != 'false'
        ${system_id}    Collections.Get From Dictionary     ${response.json()}      ehrId
                        Set Suite Variable    ${ehr_id}     ${ehrId}
                        #Log To Console    \n\tDEBUG OUTPUT - EHR_ID: \n\t${ehr_id}
                        Return From Keyword
    ELSE
        Set Suite Variable      ${system_id}       ${resp.json()['system_id']['value']}
        #Log To Console    \n\tDEBUG OUTPUT - SYSTEM_ID: \n\t${system_id}[0]
    END

check that headers location response has
   [Documentation]      Extract `Protocol, Host, Port` from Location headers response of preceding request.
   ...                  DEPENDENCY: `create new EHR`
   ...                  Expected result is the list of arguments, in the following order:
   ...                  Protocol  Host  Port
   ...                  Example of arguments: https  example.com  333
   ...                  Takes a list of 3 arguments, to compare expected with actual location protocol, host, port values.
   [Arguments]          @{expectedLocationInfo}
   @{tokenized_uri}         Split String    ${response.headers['Location']}   /
   ${tmpProtocol}          Remove String   ${tokenized_uri}[0]     :
   ${locationProtocol}      Set Variable     ${tmpProtocol}
   ${tmpHost}              Set Variable     ${tokenized_uri}[2]
   @{hostPortList}          Split String     ${tmpHost}     :
   ${locationHost}          Set Variable        ${hostPortList}[0]
   ${locationPort}          Set Variable       ${hostPortList}[1]
   Should be equal as strings    ${expectedLocationInfo}[0]    ${locationProtocol}
   Should be equal as strings    ${expectedLocationInfo}[1]    ${locationHost}
   Should be equal as strings    ${expectedLocationInfo}[2]    ${locationPort}
   Log To Console    \n\tDEBUG OUTPUT - Location Protocol: \n\t${locationProtocol}
   Log To Console    \n\tDEBUG OUTPUT - Location Host: \n\t${locationHost}
   Log To Console    \n\tDEBUG OUTPUT - Location Port: \n\t${locationPort}
   Set Suite Variable    ${locationProtocol}
   Set Suite Variable    ${locationHost}
   Set Suite Variable    ${locationPort}

check that composition headers location response has
   [Documentation]      Extract `Protocol, Host, Port` from Location headers response of preceding request.
   ...                  DEPENDENCY: `commit composition`
   ...                  Expected result is the list of arguments, in the following order:
   ...                  Protocol  Host  Port
   ...                  Example of arguments: https  example.com  333
   ...                  Takes a list of 3 arguments, to compare expected with actual location protocol, host, port values.
   [Arguments]          @{expectedLocationInfo}
   ${fullLocation}   Set Variable    ${response.headers['Location']}
   @{tokenized_uri}         Split String    ${fullLocation}   /
   ${tmpProtocol}          Remove String   ${tokenized_uri}[0]     :
   ${locationProtocol}      Set Variable     ${tmpProtocol}
   ${tmpHost}              Set Variable     ${tokenized_uri}[2]
   @{hostPortList}          Split String     ${tmpHost}     :
   ${locationHost}          Set Variable        ${hostPortList}[0]
   ${locationPort}          Set Variable       ${hostPortList}[1]
   Should be equal as strings    ${expectedLocationInfo}[0]    ${locationProtocol}
   Should be equal as strings    ${expectedLocationInfo}[1]    ${locationHost}
   Should be equal as strings    ${expectedLocationInfo}[2]    ${locationPort}
   Log To Console    \n\tDEBUG OUTPUT - Location Protocol: \n\t${locationProtocol}
   Log To Console    \n\tDEBUG OUTPUT - Location Host: \n\t${locationHost}
   Log To Console    \n\tDEBUG OUTPUT - Location Port: \n\t${locationPort}
   Set Suite Variable    ${locationProtocol}
   Set Suite Variable    ${locationHost}
   Set Suite Variable    ${locationPort}

check that composition body location response has
   [Documentation]      Extract `Protocol, Host, Port` from Location body response of preceding request.
   ...                  DEPENDENCY: `commit composition`
   ...                  Expected result is the list of arguments, in the following order:
   ...                  Protocol  Host  Port
   ...                  Example of arguments: https  example.com  333
   ...                  Takes a list of 3 arguments, to compare expected with actual location protocol, host, port values.
   [Arguments]          @{expectedLocationInfo}
   ${metaObj}      Get From Dictionary     ${response.json()}      meta
   ${fullLocation}      Set Variable    ${metaObj['href']['url']}
   @{tokenized_uri}         Split String    ${fullLocation}   /
   ${tmpProtocol}          Remove String   ${tokenized_uri}[0]     :
   ${locationProtocol}      Set Variable     ${tmpProtocol}
   ${tmpHost}              Set Variable     ${tokenized_uri}[2]
   @{hostPortList}          Split String     ${tmpHost}     :
   ${locationHost}          Set Variable        ${hostPortList}[0]
   ${locationPort}          Set Variable       ${hostPortList}[1]
   Should be equal as strings    ${expectedLocationInfo}[0]    ${locationProtocol}
   Should be equal as strings    ${expectedLocationInfo}[1]    ${locationHost}
   Should be equal as strings    ${expectedLocationInfo}[2]    ${locationPort}
   Log To Console    \n\tDEBUG OUTPUT - Location Protocol: \n\t${locationProtocol}
   Log To Console    \n\tDEBUG OUTPUT - Location Host: \n\t${locationHost}
   Log To Console    \n\tDEBUG OUTPUT - Location Port: \n\t${locationPort}
   Set Suite Variable    ${locationProtocol}
   Set Suite Variable    ${locationHost}
   Set Suite Variable    ${locationPort}

extract subject_id from response (JSON)
    [Documentation]     Extracts subject_id from response of preceding request.
    ...                 This KW executes only in EHR_SERVICE test suite, it is ignored
    ...                 in all over test suites.

            # comment:  Determine which test suite we are executing the KW in (based on SUITE METADATA).
            #           If test suite is one of COMPOSITION, CONTRIBUTION, DIRECTORY, EHR_STATUS, KNOWLEDGE or AQL
            #           skipp this KW completely.
                        Log    ${SUITE METADATA['TOP_TEST_SUITE']}
    ${actualsuite}      Get From Dictionary    ${SUITE METADATA}    TOP_TEST_SUITE
                        Return From Keyword If    "${actualsuite}" not in "EHR_SERVICE"
                        ...    subject_id is only needed in EHR_SERVICE test suite!

    # Pass Execution    TEMP SOLUTION    broken_test    not-ready

    #TODO: @WLAD check Github Issue #272
    #      refactor this KW or it's usage in all test suites!

    #  ${subjectid}=      String      response body ehr_status subject external_ref id value
    #                     Log To Console    \n\tDEBUG OUTPUT - EHR_STATUS SUBJECT_ID: \n\t${subjectid}[0]
    #                     Set Suite Variable    ${subject_id}    ${subjectid}[0]


extract ehr_status from response (JSON)
    [Documentation]     Extracts ehr_status-object from response of preceding request.
    ...                 DEPENDENCY: `create new EHR`
    Set Suite Variable      ${ehr_status}       ${resp.json()['ehr_status']}
    #Log To Console      \n\tDEBUG OUTPUT - EHR_STATUS: \n${ehr_status}


extract ehrstatus_uid (JSON)
    [Documentation]     Extracts uuid of ehr_status from response of preceding request.
    ...                 DEPENDENCY: `create new EHR`

    Set Suite Variable      ${ehrstatus_uid}       ${resp.json()['ehr_status']['uid']['value']}
    #Log To Console      \n\tDEBUG OUTPUT - EHR_STATUS UUID: \n${ehrstatus_uid}
    @{ehr_status_uid}       Split String        ${ehrstatus_uid}      ::
                            Set Suite Variable  ${versioned_status_uid}   ${ehr_status_uid}[0]


extract ehr_id from response (XML)
    [Documentation]     Extracts `ehr_id` from response of preceding request with content-type=xml
    ...                 DEPENDENCY: `create new EHR`

    ${xml}=             Parse Xml    ${response.content}
    ${ehr_id}=          Get Element Text    ${xml}    xpath=ehr_id/value
                        Set Test Variable   ${ehr_id}       ${ehr_id}


extract ehrstatus_uid (XML)
    [Documentation]     Extracts uuid of ehr_status from response of preceding request with content-type=xml
    ...                 DEPENDENCY: `create new EHR`

    ${xml}=             Parse Xml    ${response.content}
    ${ehrstatus_uid}=   Get Element Text    ${xml}    xpath=ehr_status/uid/value
                        Set Test Variable   ${ehrstatus_uid}    ${ehrstatus_uid}

extract system_id from response (XML)
    [Documentation]     Extracts `system_id` from response of preceding request with content-type=xml
    ...                 DEPENDENCY: `create new EHR`

    ${xml}=             Parse Xml    ${response.content}
    ${system_id}=       Get Element Text    ${xml}    xpath=system_id/value
                        Set Test Variable   ${system_id}    ${system_id}


create fake EHR
    generate random ehr_id
    generate random subject_id


create fake EHR not hexadecimal
    [Documentation]     Set invalid ehr_id that is not hexadecimal (for alternative scenarios)

    ${ehr_id}=          Set Variable   XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
    Set Test Variable   ${ehr_id}    ${ehr_id}


create fake EHR not match pattern
    [Documentation]     Set invalid ehr_id that is not match the UUID pattern 8-4-4-4-12 (for alternative scenarios)

    ${ehr_id}=          Evaluate    str(uuid.uuid4())    uuid
    ${ehr_id}=          Get Substring    ${ehr_id}    0    -2
    Set Test Variable   ${ehr_id}    ${ehr_id}


generate random ehr_id
    [Documentation]     Generates a random UUIDv4 spec conform `ehr_id`
    ...                 and exposes it as Test Variable

    ${ehr_id}=          Evaluate    str(uuid.uuid4())    uuid
                        Set Suite Variable    ${ehr_id}    ${ehr_id}


generate random subject_id
    [Documentation]     Generates a random UUIDv4 spec conform `subject_id`
    ...                 and exposes it as Test Variable

    ${subjectid}=       Evaluate    str(uuid.uuid4())    uuid
                        Set Suite Variable    ${subject_id}    ${subjectid}


generate fake ehr_status
    [Documentation]     Loads a default ehr_status JSON object from test_data_sets folder
    ...                 and exposes it as Test Variable.

    ${json_ehr_status}  Load JSON From File  ${VALID EHR DATA SETS}/000_ehr_status.json
                        Set Test Variable    ${ehr_status}    ${json_ehr_status}
                        Output    ${ehr_status}


set is_queryable / is_modifiable
    [Arguments]         ${is_modifiable}=${TRUE}    ${is_queryable}=${TRUE}
    [Documentation]     Sets boolean values of is_queryable / is_modifiable.
    ...                 Both default to ${TRUE},
    ...                 Valid Values: ${TRUE}, ${FALSE},
    ...                 DEPENDENCY: keywords that expose a `${ehr_status}` variable
    ...                 e.g. `generate fake ehr_status`

                        modify ehr_status is_modifiable to    ${is_modifiable}
                        modify ehr_status is_queryable to    ${is_queryable}


modify ehr_status is_queryable to
    [Arguments]         ${value}
    [Documentation]     Modifies `is_queryable` property of ehr_status JSON object
    ...                 and exposes  `ehr_status` Test Variable.
    ...                 DEPENDENCY: keywords that expose and `ehr_status` variable
    ...                 Valid values: `${FALSE}`, `${TRUE}`

    ${value}=           Set Variable If    $value=="true" or $value=="false"
                        ...    ${{bool(distutils.util.strtobool($value))}}
                        # comment: else leave it as is
                        ...    ${value}
    ${value}=           Set Variable If    $value=='"true"' or $value=='"false"'
                        ...    ${{$value.strip('"')}}
                        # comment: else
                        ...    ${value}
    ${value}=           Set Variable If    $value=="0" or $value=="1"
                        ...    ${{int($value)}}
                        # comment: else
                        ...    ${value}
    ${value}=           Set Variable If    $value=="null"
                        ...    ${{None}}
                        # comment: else
                        ...    ${value}
    ${value}=           Set Variable If    $value=='"null"'
                        ...    ${{$value.strip('"')}}
                        # comment: else
                        ...    ${value}
    ${ehr_status}=      Update Value To Json  ${ehr_status}  $..is_queryable  ${value}
                        # NOTE: alternatively u can save output to file
                        # Output   ${ehr_status}[0]             # ehr_status.json
                        Set Test Variable    ${ehr_status}    ${ehr_status}


modify ehr_status is_modifiable to
    [Arguments]         ${value}
    [Documentation]     Modifies `is_queryable` property of ehr_status JSON object
    ...                 and exposes  `ehr_status` Test Variable.
    ...                 DEPENDENCY: `get ehr_status from response`
    ...                 Valid values: `${FALSE}`, `${TRUE}`

    ${value}=           Set Variable If    $value=="true" or $value=="false"
                        ...    ${{bool(distutils.util.strtobool($value))}}
                        # comment: else
                        ...    ${value}
    ${value}=           Set Variable If    $value=='"true"' or $value=='"false"'
                        ...    ${{$value.strip('"')}}
                        # comment: else
                        ...    ${value}
    ${value}=           Set Variable If    $value=="0" or $value=="1"
                        ...    ${{int($value)}}
                        # comment: else
                        ...    ${value}
    ${value}=           Set Variable If    $value=="null"
                        ...    ${{None}}
                        # comment: else
                        ...    ${value}
    ${value}=           Set Variable If    $value=='"null"'
                        ...    ${{$value.strip('"')}}
                        # comment: else
                        ...    ${value}
    ${ehr_status}=      Update Value To Json  ${ehr_status}  $..is_modifiable  ${value}
                        # Output   ${ehr_status}[0]             # ehr_status.json
                        Set Test Variable    ${ehr_status}    ${ehr_status}


create new EHR with subject_id and default subject id value (JSON)

    ${ehr_status_json}  Load JSON From File   ${VALID EHR DATA SETS}/0000_ehr_status_hardcoded_subject_id_value.json

    ${resp}     POST On Session     ${SUT}    /ehr      json=${ehr_status_json}
                ...     expected_status=anything        headers=${headers}
                Set Suite Variable    ${response}    ${resp}

                extract ehr_id from response (JSON)
                extract system_id from response (JSON)
                extract ehr_status from response (JSON)


# Output Debug Info To Console
#     [Documentation]     Prints all details of a request to console in JSON style.
#     ...                 - request headers
#     ...                 - request body
#     ...                 - response headers
#     ...                 - response body
#     Output







# oooooooooo.        .o.         .oooooo.   oooo    oooo ooooo     ooo ooooooooo.
# `888'   `Y8b      .888.       d8P'  `Y8b  `888   .8P'  `888'     `8' `888   `Y88.
#  888     888     .8"888.     888           888  d8'     888       8   888   .d88'
#  888oooo888'    .8' `888.    888           88888[       888       8   888ooo88P'
#  888    `88b   .88ooo8888.   888           888`88b.     888       8   888
#  888    .88P  .8'     `888.  `88b    ooo   888  `88b.   `88.    .8'   888
# o888bood8P'  o88o     o8888o  `Y8bood8P'  o888o  o888o    `YbodP'    o888o
#
# [ BACKUP ]

# start request session
#     [Arguments]         ${content_type}
#     [Documentation]     Prepares settings for RESTInstace HTTP request.
#     Run Keyword If      "${content_type}"=="XML"   set content-type to XML
#     Run Keyword If      "${content_type}"=="JSON"  set content-type to JSON
#     Set Headers          ${authorization}
#     Set Headers          ${headers}

# set content-type to XML
#     [Documentation]     Set headers accept and content-type to XML.
#     ...                 DEPENDENCY: `start request session`
#     &{headers}=         Create Dictionary    Content-Type=application/xml
#                         ...                  Accept=application/xml
#                         ...                  Prefer=return=representation
#                         Set Test Variable    ${headers}    ${headers}

# set content-type to JSON
#     [Documentation]     Set headers accept and content-type to JSON.
#     ...                 DEPENDENCY: `start request session`
#     &{headers}=         Create Dictionary    Content-Type=application/json
#                         ...                  Accept=application/json
#                         ...                  Prefer=return=representation
#                         Set Test Variable    ${headers}    ${headers}
#                         # NOTE: EHRSCAPE fails to create EHR with `POST /ehr`
#                         #       when Content-Type=application/json is set
#                         #       But this is default header of RESTInstance lib!
#                         #       Do this "Content-Type=      " to unset it!      # BE AWARE!!


# create ehr without query params
#     [Arguments]  ${body}=None
#     &{resp}=    REST.POST    /ehr  body=${body}
#     Integer    response status    200  201  202  208  400
#     Set Test Variable    ${response}    ${resp}
#     [Teardown]  KE @Dev subjectId and subjectNamespace must be optional - tag(s): not-ready

# create ehr with query params
#     [Arguments]  ${queryparams}  ${body}=None
#     &{resp}=    REST.POST    /ehr?${queryparams}  body=${body}
#     Integer    response status    200  201  202  208  400
#     Set Test Variable    ${response}    ${resp}
#     [Teardown]  KE @Dev Not expected behavior - tag(s): not-ready

# extract ehrId
#
#     Log  DEPRECATION WARNING - @WLAD replace/remove this keyword!
#     ...  level=WARN
#
#     Set Test Variable    ${ehr_id}    ${response.body.ehrId}

# generate fake ehr_status with queryable = false
#
#     ${json_ehr_status}=     Load JSON From File   ${FIXTURES}/ehr/ehr_status_1_api_spec.json
#     ${json_ehr_status}=     Update Value To Json  ${json_ehr_status}   $..is_queryable   false
#
#                             Set Test Variable    ${ehr_status}    ${json_ehr_status}
#
#                             Output    ${ehr_status}

# generate fake ehr_status with modifiable = false
#
#     ${json_ehr_status}=     Load JSON From File   ${FIXTURES}/ehr/ehr_status_1_api_spec.json
#     ${json_ehr_status}=     Update Value To Json  ${json_ehr_status}   $..is_modifiable   false
#
#                             Set Test Variable    ${ehr_status}    ${json_ehr_status}
#
#                             Output    ${ehr_status}

# verify ehrStatus queryable
#     [Arguments]   ${is_queryable}
#     ${QUERYALBE}=  Run Keyword If  "${is_queryable}"==""  Set Test Variable    ${is_queryable}    ${TRUE}
#     Boolean  $.ehrStatus.queryable  ${is_queryable}
#     #[Teardown]   Run keyword if  "${KEYWORD STATUS}"=="FAIL"  log a WARNING and set tag not-ready

# verify ehrStatus modifiable
#     [Arguments]   ${is_modifiable}
#     ${MODIFIABLE}=  Run Keyword If  "${is_modifiable}"==""  Set Test Variable    ${is_modifiable}    ${TRUE}
#     Boolean  $.ehrStatus.modifiable  ${is_modifiable}
#     #[Teardown]   Run keyword if  "${KEYWORD STATUS}"=="FAIL"  log a WARNING and set tag not-ready

# update ehr
#     [Arguments]    ${ehr_id}
#     &{resp}=    REST.PUT    /ehr/${ehr_id}/status    ${CURDIR}${/}../fixtures/ehr/update_body.json
#     Set Test Variable    ${response}    ${resp}
#     Integer    response status    200  401  403  404
#     # Output    response body

# get ehr by subject-id and namespace
#     [Arguments]    ${subject_id}    ${namespace}
#     &{resp}=    REST.GET    /ehr?subjectId=${subject_id}&subjectNamespace=${namespace}
#     Set Test Variable    ${response}    ${resp}

# get ehr by id
#     [Arguments]    ${ehr_id}
#     &{resp}=    REST.GET    /ehr/${ehr_id}
#     Set Test Variable    ${response}    ${resp}

# verify subject_id
#     [Arguments]    ${subject_id}
#     Should be equal as strings    ${subject_id}    ${response.body.ehrStatus['subjectId']}

# verify subject_namespace
#     [Arguments]    ${subject_namespace}
#     Should be equal as strings    ${subject_namespace}    ${response.body.ehrStatus['subjectNamespace']}

# verify response action
#     [Arguments]    ${action}
#     Should Be Equal As Strings    ${action}    ${response.body['action']}



# Determine which test suite we are executing a KW in (based on TEST TAGS)
#     # comment:          If actual suite is one from the ignore list, this KW is skipped.
#     # NOTE: THIS DOES NOT WORK WHEN KW IS EXECUTED INSIDE SUTE SETUP, cause TEST TAGS are
#     #       NOT available in SETUPs
#
#     ${suitestoignore}   Create List    COMPOSITION  CONTRIBUTION  DIRECTORY  EHR_STATUS  KNOWLEDGE  AQL
#                         Log    ${TEST TAGS}[0]
#     ${actualsuite}      Set Variable    ${{$TEST_TAGS[0]}}
#                         Return From Keyword If    "${actualsuite}" in ${suitestoignore}
#                         ...    We don't need the subject_id in this test suite!


# Alternative JSHON PATH syntax for use w/ "Update Value To Json" KW
#     Update Value To Json    ${json}   $.subject.external_ref.id.value    ${subject_id}
#     Update Value To Json    ${json}   $['subject']['external_ref']['id']['value']   ${subject_id}