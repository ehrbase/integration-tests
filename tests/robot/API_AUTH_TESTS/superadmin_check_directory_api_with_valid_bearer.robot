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
Resource        ../_resources/keywords/directory_keywords.robot


*** Variables ***
${typeOfUserGeneral}   superadmin


*** Test Cases ***
Create Directory
    [Setup]     Create EHR With Super Admin User
    Set Suite Variable   ${typeOfUser}      ${typeOfUserGeneral}
    Set Credentials For User    ${typeOfUser}
    Obtain Access Token From Keycloak Using User Credentials
    Create Headers Dict And Set Directory Headers With Authorization Bearer
    load valid dir test-data-set     empty_directory.json
    ${resp}     POST On Session      ${SUT}    /ehr/${ehr_id}/directory/     expected_status=anything
                ...                  json=${test_data}      headers=${headers}
                Should Be Equal As Strings      ${resp.status_code}         ${201}
                Log     Directory ID: ${resp.json()['uid']['value']}
                Set Suite Variable      ${preceding_version_uid}    ${resp.json()['uid']['value']}

Update Directory
    Execute Precondition And Set Directory Headers
    Set To Dictionary   ${headers}
    ...         If-Match=${preceding_version_uid}
    load valid dir test-data-set    update/2_add_subfolders.json
    ${resp}     PUT On Session      ${SUT}    /ehr/${ehr_id}/directory/     expected_status=anything
                ...                  json=${test_data}      headers=${headers}
                Should Be Equal As Strings      ${resp.status_code}         ${200}
                Log     Directory ID - second version: ${resp.json()['uid']['value']}
                Set Suite Variable      ${preceding_version_uid_v2}     ${resp.json()['uid']['value']}

Get Directory
    ${resp}     GET On Session      ${SUT}    /ehr/${ehr_id}/directory      expected_status=anything
                Should Be Equal As Strings      ${resp.status_code}         ${200}
                Should Be Equal As Strings      ${resp.json()['uid']['value']}      ${preceding_version_uid_v2}

Get Directory By EHR Id and Version Uid
    ${resp}     GET On Session      ${SUT}    /ehr/${ehr_id}/directory/${preceding_version_uid_v2}
                ...         expected_status=anything
                Should Be Equal As Strings      ${resp.status_code}         ${200}
                Should Be Equal As Strings      ${resp.json()['uid']['value']}      ${preceding_version_uid_v2}

Delete Directory
    Set To Dictionary   ${headers}
    ...         If-Match=${preceding_version_uid_v2}
    ${resp}     Delete On Session      ${SUT}    /ehr/${ehr_id}/directory   headers=${headers}
                ...         expected_status=anything
                Should Be Equal As Strings      ${resp.status_code}         ${204}
                Should Be Equal As Strings      ${resp.content}             ${EMPTY}


*** Keywords ***
Precondition
    Set Credentials For User    ${typeOfUser}
    Obtain Access Token From Keycloak Using User Credentials
    Log     ${response_body}
    Log     ${response_access_token}
    Set Suite Variable      ${response_access_token}

Create Headers Dict And Set Directory Headers With Authorization Bearer
    &{headers}          Create Dictionary     &{EMPTY}
    Set To Dictionary   ${headers}
    ...     content=application/json     accept=application/json      Prefer=return=representation
    ...     Content-Type=application/json
    ...     Authorization=Bearer ${response_access_token}
    Set Suite Variable       ${headers}      ${headers}
    Create Session      ${SUT}    ${BASEURL}    debug=2   headers=${headers}

Execute Precondition And Set Directory Headers
    Precondition
    Create Headers Dict And Set Directory Headers With Authorization Bearer