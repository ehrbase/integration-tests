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
Resource        ../_resources/keywords/template_opt1.4_keywords.robot
Resource        ../_resources/keywords/contribution_keywords.robot


*** Variables ***
${typeOfUserGeneral}   doctor


*** Test Cases ***
Create Contribution
    Create EHR With Super Admin User
    Create Template With Super Admin User   minimal/minimal_evaluation.opt
    ${typeOfUser}   Set Variable    ${EMPTY}
    Set Test Variable      ${typeOfUser}   ${typeOfUserGeneral}
    Set Suite Variable     ${typeOfUser}
    Precondition
    load valid test-data-set    minimal/minimal_evaluation.contribution.json
    ${resp}     POST On Session     ${SUT}   /ehr/${ehr_id}/contribution   expected_status=anything
                ...                 json=${test_data}
                ...                 headers=${headers}
                Should Be Equal As Strings      ${resp.status_code}         ${201}
                Set Suite Variable    ${contribution_uid}       ${resp.json()['uid']['value']}
                Set Suite Variable    ${versions}       ${resp.json()['versions']}
                Set Suite Variable    ${version_id}     ${resp.json()['versions'][0]['id']['value']}
                Set Suite Variable    ${change_type}    ${resp.json()['audit']['change_type']['value']}

Get Contribution By Id
    ${resp}     GET On Session     ${SUT}   /ehr/${ehr_id}/contribution/${contribution_uid}   expected_status=anything
                ...                 headers=${headers}
                Should Be Equal As Strings      ${resp.status_code}         ${200}
                Should Be Equal As Strings      ${contribution_uid}         ${resp.json()['uid']['value']}


*** Keywords ***
Precondition
    Set Credentials For User    ${typeOfUser}
    Obtain Access Token From Keycloak Using User Credentials
    Log     ${response_body}
    Log     ${response_access_token}
    Set Suite Variable      ${response_access_token}
    Create Session      ${SUT}    ${BASEURL}    debug=2
    &{headers}          Create Dictionary     &{EMPTY}
    Set To Dictionary   ${headers}
    ...     Prefer=return=representation
    ...     Authorization=Bearer ${response_access_token}
    Set Suite Variable      ${headers}