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
Documentation   API Authorization Test Suite to check Event Trigger CRUD

Resource        ../_resources/keywords/api_auth_keywords.robot
Resource        ../_resources/keywords/event_trigger_keywords.robot


*** Variables ***
${typeOfUserGeneral}   doctor


*** Test Cases ***
Create Event Trigger With Valid Authorization Bearer
    Create Event Trigger With Super Admin User
    Set Suite Variable   ${typeOfUser}      ${typeOfUserGeneral}
    Set Credentials For User    ${typeOfUser}
    Obtain Access Token From Keycloak Using User Credentials
    Log     ${response_body}
    Log     ${response_access_token}
    Set Suite Variable      ${response_access_token}
    ${file}         Load Json From File     ${VALID EVENT TRIGGER DATA SETS}/create/main_event_trigger.json
    ${json_str}     Generate Event Trigger Id And Update File Content       ${file}
    Create Session With Valid Authorization Bearer
    ${resp}         POST On Session     eventtriggersut
    ...             /event-trigger/service      expected_status=anything
    ...             data=${json_str}
                    Should Be Equal As Strings      ${resp.status_code}         403
                    #Should Be Equal As Strings      ${resp.json()['error']}     Forbidden
                    #Should Be Equal As Strings      ${resp.json()['message']}
                    #...         Access Denied because of missing scope:

Create Event Trigger Without Authorization Bearer
    ${file}         Load Json From File     ${VALID EVENT TRIGGER DATA SETS}/create/main_event_trigger.json
    ${json_str}     Generate Event Trigger Id And Update File Content       ${file}
    Create Session Without Authorization Bearer
    ${resp}         POST On Session     eventtriggersut
    ...             /event-trigger/service      expected_status=anything
    ...             data=${json_str}
                    Should Be Equal As Strings          ${resp.status_code}     401

Get All Event Triggers With Valid Authorization Bearer
    Create Session With Valid Authorization Bearer
    ${resp}         GET On Session      eventtriggersut      /event-trigger/service     expected_status=anything
                    Should Be Equal As Strings      ${resp.status_code}         403
                    #Should Be Equal As Strings      ${resp.json()['error']}     Forbidden
                    #Should Be Equal As Strings      ${resp.json()['message']}
                    #...         Access Denied because of missing scope:

Get All Event Triggers Without Authorization Bearer
    Create Session Without Authorization Bearer
    ${resp}         GET On Session      eventtriggersut      /event-trigger/service     expected_status=anything
                    Should Be Equal As Strings      ${resp.status_code}     401

Get Event Trigger By UUId With Valid Authorization Bearer
    [Documentation]     ${event_uuid} is took from first test, used to create Event Trigger
    Create Session With Valid Authorization Bearer
    ${resp}         GET On Session      eventtriggersut      /event-trigger/service/${event_uuid}
                    ...     expected_status=anything
                    Should Be Equal As Strings      ${resp.status_code}         403
                    #Should Be Equal As Strings      ${resp.json()['error']}     Forbidden
                    #Should Be Equal As Strings      ${resp.json()['message']}
                    #...         Access Denied because of missing scope:

Get Event Trigger By UUId Without Authorization Bearer
    [Documentation]     ${event_uuid} is took from first test, used to create Event Trigger
    Create Session Without Authorization Bearer
    ${resp}         GET On Session      eventtriggersut      /event-trigger/service/${event_uuid}
                    ...     expected_status=anything
                    Should Be Equal As Strings       ${resp.status_code}        401
                    Set Test Variable   ${response}     ${resp}
                    Set Test Variable   ${response_event_trigger}   ${resp.content}

Deactivate Event Trigger With Valid Authorization Bearer
    Create Session With Valid Authorization Bearer
    ${resp}         PUT On Session      eventtriggersut      /event-trigger/service/${event_uuid}
                    ...     expected_status=anything
                    ...     params=activate=false
                    Should Be Equal As Strings      ${resp.status_code}         403
                    #Should Be Equal As Strings      ${resp.json()['error']}     Forbidden
                    #Should Be Equal As Strings      ${resp.json()['message']}
                    #...         Access Denied because of missing scope:

Deactivate Event Trigger Without Authorization Bearer
    Create Session Without Authorization Bearer
    ${resp}         PUT On Session      eventtriggersut      /event-trigger/service/${event_uuid}
                    ...     expected_status=anything
                    ...     params=activate=false
                    Should Be Equal As Strings      ${resp.status_code}         401

Activate Event Trigger With Valid Authorization Bearer
    Create Session With Valid Authorization Bearer
    ${resp}         PUT On Session      eventtriggersut      /event-trigger/service/${event_uuid}
                    ...     expected_status=anything
                    ...     params=activate=true
                    Should Be Equal As Strings      ${resp.status_code}         403
                    #Should Be Equal As Strings      ${resp.json()['error']}     Forbidden
                    #Should Be Equal As Strings      ${resp.json()['message']}
                    #...         Access Denied because of missing scope:

Activate Event Trigger Without Authorization Bearer
    Create Session Without Authorization Bearer
    ${resp}         PUT On Session      eventtriggersut      /event-trigger/service/${event_uuid}
                    ...     expected_status=anything
                    ...     params=activate=true
                    Should Be Equal As Strings      ${resp.status_code}         401

Delete Event Trigger By UUID Without Authorization Bearer
    Create Session Without Authorization Bearer
    ${resp}         DELETE On Session   eventtriggersut      /event-trigger/service/${event_uuid}
                    ...     expected_status=anything
                    Should Be Equal As Strings      ${resp.status_code}         401

Delete Event Trigger By UUID With Valid Authorization Bearer
    Create Session With Valid Authorization Bearer
    ${resp}         DELETE On Session   eventtriggersut      /event-trigger/service/${event_uuid}
                    ...     expected_status=anything
                    Should Be Equal As Strings      ${resp.status_code}         403
                    #Should Be Equal As Strings      ${resp.json()['error']}     Forbidden
                    #Should Be Equal As Strings      ${resp.json()['message']}
                    #...         Access Denied because of missing scope:


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
    Create Session      eventtriggersut    ${PLUGINURL}
                    ...     debug=2     headers=${headers}     verify=True
                    Set Suite Variable   ${headers}      ${headers}

Create Session Without Authorization Bearer
    &{headers}      Create Dictionary   Content-Type=application/json
                    ...     Accept=application/json
    Create Session      eventtriggersut    ${PLUGINURL}
                    ...     debug=2     headers=${headers}     verify=True
                    Set Test Variable   ${headers}      ${headers}