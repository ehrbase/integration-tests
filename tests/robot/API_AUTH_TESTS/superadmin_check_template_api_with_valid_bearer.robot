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


*** Variables ***
${typeOfUser}   superadmin


*** Test Cases ***
Create Template
    [Setup]     Precondition
    REST.POST        ${BASEURL}/template/adl1.4
        Integer         response status    404
        String          response body error    Not Found

Get All Templates
    REST.GET        ${BASEURL}/template/adl1.4
        Integer         response status    404
        String          response body error    Not Found

Get Template By Id
    REST.GET        ${BASEURL}/template/adl1.4/my_test_template
        Integer         response status    404
        String          response body error    Not Found

Get Example By Template Id
    REST.GET        ${BASEURL}/template/adl1.4/my_test_template/example
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