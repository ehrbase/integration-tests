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
Documentation   API Authorization Test Suite to check EHRBASE API

Resource        ../_resources/keywords/api_auth_keywords.robot
Resource        ../_resources/keywords/ehr_keywords.robot
Resource        ../_resources/keywords/directory_keywords.robot
Resource        ../_resources/keywords/contribution_keywords.robot


*** Variables ***
${typeOfUserGeneral}    superadmin
${SECURITY_AUTHTYPE}    oauth


*** Test Cases ***
Update EHR
    Create EHR With Super Admin User
    ${typeOfUser}   Set Variable    ${EMPTY}
    Set Test Variable      ${typeOfUser}   ${typeOfUserGeneral}
    Set Suite Variable     ${typeOfUser}
    Set Credentials For User    ${typeOfUser}
    Obtain Access Token From Keycloak Using User Credentials
    Log     ${response_body}
    Log     ${response_access_token}
    Set Suite Variable      ${response_access_token}
    Set Headers     { "Authorization": "Bearer ${response_access_token}" }
    REST.PUT        ${ADMIN_BASEURL}/ehr/${ehr_id}
        Integer         response status    200

Update Template
    ${resp}     REST.PUT        ${ADMIN_BASEURL}/template/my_test_template
    Should Not Be Equal As Strings     ${resp['status']}    ${403}

Delete Template
    ${resp}     REST.DELETE     ${ADMIN_BASEURL}/template/my_test_template
    Should Not Be Equal As Strings     ${resp['status']}    ${403}

Get EHRBase Status
    REST.GET     ${ADMIN_BASEURL}/status
        Integer         response status             403
        String          response body error         Forbidden
        String          response body message
        ...             Access Denied because of missing scope: ehrbase:system:read

Delete Directory
    generate fake version_uid
    ${resp}     REST.DELETE     ${ADMIN_BASEURL}/ehr/${ehr_id}/directory/${version_uid}
    Should Not Be Equal As Strings     ${resp['status']}    ${403}

Delete Composition
    generate random composition_uid
    Set Suite Variable   ${composition_uid}
    Set Suite Variable   ${versioned_object_uid}
    Set Suite Variable   ${version_uid}
    Set Suite Variable   ${preceding_version_uid}
    REST.DELETE     ${ADMIN_BASEURL}/ehr/${ehr_id}/composition/${composition_uid}
        Integer         response status    204

Update Contribution
    generate random contribution_uid
    REST.PUT     ${ADMIN_BASEURL}/ehr/${ehr_id}/contribution/${contribution_uid}
        Integer         response status    200

Delete Contribution
    generate random contribution_uid
    ${resp}     REST.DELETE     ${ADMIN_BASEURL}/ehr/${ehr_id}/contribution/${contribution_uid}
    Should Not Be Equal As Strings     ${resp['status']}    ${403}

Delete EHR
    REST.DELETE     ${ADMIN_BASEURL}/ehr/${ehr_id}
        Integer         response status    204


*** Keywords ***
Precondition
    Set Credentials For User    ${typeOfUser}
    Obtain Access Token From Keycloak Using User Credentials
    Log     ${response_body}
    Log     ${response_access_token}
    Set Suite Variable      ${response_access_token}
    Set Headers     { "Authorization": "Bearer ${response_access_token}" }