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
Resource        ../_resources/keywords/template_opt1.4_keywords.robot


*** Variables ***
${typeOfUser}   superadmin


*** Test Cases ***
Create Template
    [Tags]      not-ready   bug
    [Setup]     Precondition
    Create Headers Dict And Set Template Headers With Authorization Bearer
    get valid OPT file    nested/nested.opt
    ${resp}     POST On Session      ${SUT}    /definition/template/adl1.4   expected_status=anything
                ...                  data=${file}    headers=${headers}
                IF      ${resp.status_code} == ${201} or ${resp.status_code} == ${409}
                    Log     Passed
                ELSE
                    Fail    ${resp.status_code} was returned for Create template with user ${typeOfUser}
                END

Get All Templates
    Create Headers Dict And Set Template Headers With Authorization Bearer
    ${resp}     GET On Session      ${SUT}    /definition/template/adl1.4
                ...     expected_status=anything    headers=${headers}
                Should Be Equal As Strings      ${resp.status_code}         ${200}
                Log      ${resp.json()}

Get Template By Id
    [Tags]      not-ready   bug
    Create Headers Dict And Set Template Headers With Authorization Bearer
    ${resp}     GET On Session      ${SUT}    /definition/template/adl1.4/nested.en.v1
                ...     expected_status=anything    headers=${headers}
                Should Be Equal As Strings      ${resp.status_code}         ${200}

Get Example By Template Id
    Create Headers Dict And Set Template Headers With Authorization Bearer
    ${resp}     GET On Session      ${SUT}    /definition/template/adl1.4/nested.en.v1/example
                ...     expected_status=anything    headers=${headers}
                Should Be Equal As Strings      ${resp.status_code}         ${200}
                Should Contain      ${resp.json()['uid']['value']}      -
    Delete All Sessions


*** Keywords ***
Precondition
    Set Credentials For User    ${typeOfUser}
    Obtain Access Token From Keycloak Using User Credentials
    Log     ${response_body}
    Log     ${response_access_token}
    Set Suite Variable      ${response_access_token}
    Create Session      ${SUT}    ${BASEURL}    debug=2

Create Headers Dict And Set Template Headers With Authorization Bearer
    &{headers}          Create Dictionary     &{EMPTY}
    Set To Dictionary   ${headers}
    ...     content=application/xml     accept=application/json      Prefer=return=representation
    ...     Content-Type=application/xml
    ...     Authorization=Bearer ${response_access_token}
    Set Test Variable       ${headers}      ${headers}