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
${typeOfUser}   doctor


*** Test Cases ***
Create Composition
    [Setup]     Precondition
    generate random ehr_id
    REST.POST        ${BASEURL}/ehr/${ehr_id}/composition/
        Integer         response status    400
        String          response body error    Bad Request

Update Composition
    REST.PUT        ${BASEURL}/ehr/${ehr_id}/composition/${versioned_object_uid}
        Integer         response status    400
        String          response body error    Bad Request

Get Composition By Version Id
    REST.GET        ${BASEURL}/ehr/${ehr_id}/composition/${version_uid}
        Integer         response status    404
        String          response body error    Not Found

Get Composition By Version Id And Timestamp
    ${date}=    DateTime.Get Current Date     result_format=%Y-%m-%dT%H:%M:%S.%f
    REST.GET        ${BASEURL}/ehr/${ehr_id}/composition/${version_uid}?${date}
        Integer         response status    404
        String          response body error    Not Found

Delete Composition
    REST.GET        ${BASEURL}/ehr/${ehr_id}/composition/${version_uid}
        Integer         response status    404
        String          response body error    Not Found
    Delete All Sessions



*** Keywords ***
Precondition
    Set Credentials For User    ${typeOfUser}
    Obtain Access Token From Keycloak Using User Credentials
    Log     ${response_body}
    Log     ${response_access_token}
    Set Suite Variable      ${response_access_token}
    Set Headers     { "Authorization": "Bearer ${response_access_token}" }
    generate random composition_uid
    Set Suite Variable   ${composition_uid}
    Set Suite Variable   ${versioned_object_uid}
    Set Suite Variable   ${version_uid}
    Set Suite Variable   ${preceding_version_uid}