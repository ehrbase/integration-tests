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
${typeOfUser}   doctor


*** Test Cases ***
Create EHR
    [Setup]     Precondition
    generate random ehr_id
    REST.POST        ${BASEURL}/ehr
        Integer         response status    204

Update EHR
    REST.PUT        ${BASEURL}/ehr/${ehr_id}
        Integer         response status    204

Get All EHRS
    REST.GET        ${BASEURL}/ehr
        Integer         response status    400
        String          response body error    Bad Request

Get EHR BY EHR Id
    REST.GET        ${BASEURL}/ehr/${ehr_id}
        Integer         response status    200
        String          response body ehr_id value    ${ehr_id}

Update EHR Status
    REST.PUT        ${BASEURL}/ehr/${ehr_id}/ehr_status
        Integer         response status    400
        String          response body error    Bad Request

Get EHR Status By Version Name
    REST.GET        ${BASEURL}/ehr/${ehr_id}/ehr_status
         Integer        response status    200
         String         response body archetype_node_id    openEHR-EHR-EHR_STATUS.generic.v1

Get EHR Status By Version Id
    REST.GET        ${BASEURL}/ehr/${ehr_id}/ehr_status/${ehr_id}::${CREATING_SYSTEM_ID}::2
         Integer        response status    404
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
