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
${typeOfUser}   nurse


*** Test Cases ***
Create EHR
    [Setup]     Precondition
    Create Headers Dict And Set EHR Headers With Authorization Bearer
    ${resp}     POST On Session      ${SUT}    /ehr     expected_status=anything
                ...                  headers=${headers}
                Should Be Equal As Strings      ${resp.status_code}         ${403}
                Should Be Equal As Strings      ${resp.json()['error']}     Forbidden
                Should Be Equal As Strings      ${resp.json()['message']}
                ...                 Access Denied because of missing scope: ehrbase:ehr:create

Update EHR
    Create Headers Dict And Set EHR Headers With Authorization Bearer
    create fake EHR
    ${resp}     PUT On Session      ${SUT}    /ehr/${ehr_id}    expected_status=anything
                ...                 headers=${headers}
                Should Be Equal As Strings      ${resp.status_code}         ${403}
                Should Be Equal As Strings      ${resp.json()['error']}     Forbidden
                Should Be Equal As Strings      ${resp.json()['message']}
                ...                 Access Denied because of missing scope: ehrbase:ehr:create


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