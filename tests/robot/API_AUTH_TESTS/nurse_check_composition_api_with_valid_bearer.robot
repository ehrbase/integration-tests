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
Resource        ../_resources/keywords/composition_keywords.robot


*** Variables ***
${typeOfUserGeneral}    nurse
${template_id}          minimal_observation


*** Test Cases ***
Create Composition
    Create EHR With Super Admin User
    Create Template With Super Admin User   minimal/minimal_observation.opt
    ${typeOfUser}   Set Variable    ${EMPTY}
    Set Test Variable      ${typeOfUser}   ${typeOfUserGeneral}
    Set Suite Variable     ${typeOfUser}
    Precondition
    Create Session      ${SUT}    ${BASEURL}
                        ...     debug=2     verify=True
    get valid OPT file  minimal/minimal_observation.composition.participations.extdatetimes.xml
    ${resp}     POST On Session     ${SUT}      /ehr/${ehr_id}/composition
                ...     expected_status=anything
                ...     data=${file}   headers=${headers}
                Should Be Equal As Strings      ${resp.status_code}         ${201}
                Set Suite Variable      ${composition_uid}      ${resp.json()['uid']['value']}
                ${short_uid}            Remove String           ${composition_uid}    ::${CREATING_SYSTEM_ID}::1
                Set Suite Variable      ${versioned_object_uid}     ${short_uid}

Update Composition
    Set To Dictionary   ${headers}
    ...     If-Match=${composition_uid}
    get valid OPT file  minimal/minimal_observation.composition.participations.extdatetimes.v2.xml
    ${resp}     PUT On Session      ${SUT}   /ehr/${ehr_id}/composition/${versioned_object_uid}
                ...     data=${file}    expected_status=anything    headers=${headers}
                Should Be Equal As Strings      ${resp.status_code}         ${200}
                Should Be Equal As Strings      ${resp.json()['uid']['value']}
                ...     ${versioned_object_uid}::${CREATING_SYSTEM_ID}::2

Get Composition By Version Id
    ${resp}     GET On Session      ${SUT}
                ...     /ehr/${ehr_id}/composition/${versioned_object_uid}::${CREATING_SYSTEM_ID}::2
                ...     headers=${headers}      expected_status=anything
                Should Be Equal As Strings      ${resp.status_code}         ${200}

Delete Composition
    ${resp}     DELETE On Session      ${SUT}
                ...     /ehr/${ehr_id}/composition/${versioned_object_uid}::${CREATING_SYSTEM_ID}::2
                ...     headers=${headers}      expected_status=anything
                Should Be Equal As Strings      ${resp.status_code}         ${403}
                Should Be Equal As Strings      ${resp.json()['error']}     Forbidden
                Should Be Equal As Strings      ${resp.json()['message']}
                ...     Access Denied because of missing scope: ehrbase:composition:delete
    Delete All Sessions


*** Keywords ***
Precondition
    Set Credentials For User    ${typeOfUser}
    Obtain Access Token From Keycloak Using User Credentials
    Log     ${response_body}
    Log     ${response_access_token}
    Set Suite Variable      ${response_access_token}
    &{headers}          Create Dictionary     &{EMPTY}
    ...         Content-Type=application/xml
    ...         Accept=application/json
    ...         Prefer=return=representation
    ...         Authorization=Bearer ${response_access_token}
    Set Suite Variable      ${headers}