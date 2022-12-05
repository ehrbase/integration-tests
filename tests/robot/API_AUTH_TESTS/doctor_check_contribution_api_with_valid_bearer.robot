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
Resource        ../_resources/keywords/contribution_keywords.robot


*** Variables ***
${typeOfUser}   doctor


*** Test Cases ***
Create Contribution
    [Setup]     Precondition
    generate random ehr_id
    REST.POST        ${BASEURL}/ehr/${ehr_id}/contribution/
        Integer         response status    400
        String          response body error    Bad Request

Get Contribution By Id
    generate random contribution_uid
    REST.GET        ${BASEURL}/ehr/${ehr_id}/contribution/${contribution_uid}
        Integer         response status    404
        String          response body error    Not Found


*** Keywords ***
Precondition
    Set Credentials For User    ${typeOfUser}
    Obtain Access Token From Keycloak Using User Credentials
    Log     ${response_body}
    Log     ${response_access_token}
    Set Suite Variable      ${response_access_token}
    Set Headers     { "Authorization": "Bearer ${response_access_token}" }