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
Documentation   API Authorization Test Suite to check Compensation plugin

Resource        ../_resources/keywords/api_auth_keywords.robot
Resource        ../_resources/keywords/contribution_keywords.robot
Resource        ../_resources/keywords/ehr_keywords.robot
Resource        ../_resources/keywords/template_opt1.4_keywords.robot


*** Variables ***
${typeOfUserGeneral}    nurse
${SECURITY_AUTHTYPE}    oauth


*** Test Cases ***
Rollback Contribution With Valid Authorization Bearer
    Create EHR With Super Admin User
    Create Template With Super Admin User   minimal/minimal_evaluation.opt
    Create Contribution With Super Admin User
    ${typeOfUser}   Set Variable    ${EMPTY}
    Set Test Variable       ${typeOfUser}   ${typeOfUserGeneral}
    Set Suite Variable      ${typeOfUser}
    Set Credentials For User    ${typeOfUser}
    Obtain Access Token From Keycloak Using User Credentials
    Log     ${response_body}
    Log     ${response_access_token}
    Set Suite Variable      ${response_access_token}
    Create Session With Valid Authorization Bearer
    ${resp}     POST On Session     compensationsut
                ...     /transaction-management/ehr/${ehr_id}/contribution/${contribution_uid}/rollback
                ...     expected_status=anything
   should be equal as strings       ${resp.status_code}     ${404}

Rollback Contribution Without Authorization Bearer
    Create Session Without Authorization Bearer
    ${resp}     POST On Session     compensationsut
                ...     /transaction-management/ehr/${ehr_id}/contribution/${contribution_uid}/rollback
                ...     expected_status=anything
   should be equal as strings       ${resp.status_code}     ${401}


*** Keywords ***
Precondition
    Set Credentials For User    ${typeOfUser}
    Obtain Access Token From Keycloak Using User Credentials
    Log     ${response_body}
    Log     ${response_access_token}
    Set Suite Variable      ${response_access_token}

Create Session With Valid Authorization Bearer
    &{headers}      Create Dictionary   Content-Type=application/json
                    ...     Accept=application/json
                    ...     Authorization=Bearer ${response_access_token}
    Create Session      compensationsut    ${PLUGINURL}
                    ...     debug=2     headers=${headers}     verify=True
                    Set Test Variable   ${headers}      ${headers}

Create Session Without Authorization Bearer
    &{headers}      Create Dictionary   Content-Type=application/json
                    ...     Accept=application/json
    Create Session      compensationsut    ${PLUGINURL}
                    ...     debug=2     headers=${headers}     verify=True
                    Set Test Variable   ${headers}      ${headers}