# Copyright (c) 2022 Vladislav Ploaia (Vitagroup - CDR Core Team)
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
Documentation   API Authorization Test Suite

Resource        ../_resources/keywords/api_auth_keywords.robot
Resource        ../_resources/keywords/ehr_keywords.robot


*** Variables ***
${typeOfUser}   superadmin


*** Test Cases ***
Create EHR
    [Setup]     Precondition
    Create Headers Dict And Set EHR Headers With Authorization Bearer
    ${resp}     POST On Session      ${SUT}    /ehr     expected_status=anything
                ...                  headers=${headers}
                Should Be Equal As Strings      ${resp.status_code}         ${201}
                Log     ${resp.json()['ehr_id']['value']}

Update EHR
    Create Headers Dict And Set EHR Headers With Authorization Bearer
    create fake EHR
    ${resp}     PUT On Session      ${SUT}    /ehr/${ehr_id}    expected_status=anything
                ...                 headers=${headers}
                Should Be Equal As Strings      ${resp.status_code}         ${201}
                Set Suite Variable      ${ehr_id}               ${resp.json()['ehr_id']['value']}
                Set Suite Variable      ${ehrstatus_uid}        ${resp.json()['ehr_status']['uid']['value']}
                ${short_uid}            Remove String           ${ehrstatus_uid}    ::${CREATING_SYSTEM_ID}::1
                Set Suite Variable      ${versioned_status_uid}     ${short_uid}
                Log     ${ehr_id}
                Log     ${ehr_status_uid}
                Log     ${versioned_status_uid}

Get EHR BY EHR Id
    Create Headers Dict And Set EHR Headers With Authorization Bearer
    ${resp}     GET On Session      ${SUT}    /ehr/${ehr_id}      expected_status=anything
                ...                 headers=${headers}
                Should Be Equal As Strings      ${resp.status_code}         ${200}
                Should Be Equal As Strings      ${resp.json()['ehr_id']['value']}   ${ehr_id}

Get EHR Status By Version Id
    Create Headers Dict And Set EHR Headers With Authorization Bearer
    ${resp}     Get On Session      ${SUT}    /ehr/${ehr_id}/ehr_status/${ehrstatus_uid}
                ...                 headers=${headers}      expected_status=anything
                Should Be Equal As Strings      ${resp.status_code}         ${200}
                Set Suite Variable      ${ehr_status}        ${resp.json()}

Update EHR Status
    Create Headers Dict And Set EHR Headers With Authorization Bearer
    Set To Dictionary   ${headers}
    ...     If-Match=${ehrstatus_uid}
    ...     Content-Type=application/json
    ${ehr_status_updated}       Update Value To Json    ${ehr_status}       $..is_queryable     ${FALSE}
    ${json_string}=    evaluate    json.dumps(${ehr_status_updated})    json
    ${resp}     PUT On Session      ${SUT}    /ehr/${ehr_id}/ehr_status     data=${json_string}
                ...                 headers=${headers}      expected_status=anything
                Should Be Equal As Strings      ${resp.status_code}         ${200}
                Log     ${resp.json()['uid']['value']}

Get EHR Status By Time
    Create Headers Dict And Set EHR Headers With Authorization Bearer
    ${resp}     Get On Session      ${SUT}    /ehr/${ehr_id}/ehr_status
                ...                 headers=${headers}      expected_status=anything
                Should Be Equal As Strings      ${resp.status_code}         ${200}
                Should Be Equal As Strings      ${resp.json()['uid']['value']}
                ...                 ${versioned_status_uid}::${CREATING_SYSTEM_ID}::2


*** Keywords ***
Precondition
    Set Credentials For User    ${typeOfUser}
    Obtain Access Token From Keycloak Using User Credentials
    Log     ${response_body}
    Log     ${response_access_token}
    Set Suite Variable      ${response_access_token}
    Create Session      ${SUT}    ${BASEURL}    debug=2

Create Headers Dict And Set EHR Headers With Authorization Bearer
    &{headers}          Create Dictionary     &{EMPTY}
    Set To Dictionary   ${headers}
    ...     content=application/json     accept=application/json      Prefer=return=representation
    ...     Authorization=Bearer ${response_access_token}
    Set Test Variable       ${headers}      ${headers}