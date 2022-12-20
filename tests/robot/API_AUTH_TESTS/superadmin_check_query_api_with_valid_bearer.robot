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
Resource        ../_resources/keywords/aql_query_keywords.robot


*** Variables ***
${typeOfUser}   superadmin


*** Test Cases ***
Execute AQL Query Ad-Hoc
    [Setup]     Precondition
    ${query}    Catenate
    ...     SELECT e/ehr_id/value as ehr_id_value,
    ...     e/system_id/value as system_id_value
    ...     FROM EHR e LIMIT 1
    Set Test Variable    ${payload}    {"q": "${query}"}
    ${resp}     POST On Session     ${SUT}   /query/aql   expected_status=anything
                ...                 data=${payload}     headers=${headers}
                Should Be Equal As Strings      ${resp.status_code}         ${200}
                Log     ${resp.json()['q']}
                Log     ${resp.json()['rows']}


*** Keywords ***
Precondition
    Set Credentials For User    ${typeOfUser}
    Obtain Access Token From Keycloak Using User Credentials
    Log     ${response_body}
    Log     ${response_access_token}
    Set Suite Variable      ${response_access_token}
    &{headers}          Create Dictionary     &{EMPTY}
    Set To Dictionary   ${headers}
    ...     Content-Type=application/json
    ...     Authorization=Bearer ${response_access_token}
    Set Suite Variable      ${headers}
    Create Session      ${SUT}    ${BASEURL}    debug=2