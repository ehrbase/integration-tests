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
Documentation   API Authorization Test Suite to check Multi-tenancy

Resource        ../_resources/keywords/api_auth_keywords.robot
Resource        ../_resources/keywords/multitenancy_keywords.robot


*** Variables ***
${typeOfUser}   nurse


*** Test Cases ***
Create Tenant With Valid Authorization Bearer
    [Setup]     Precondition
    ${tnt}     Decode JWT And Get TNT Value    ${encoded_token_1}
    Create Session      multitenancy    ${PLUGINURL}    debug=2     verify=True
    ${headers}      Create Dictionary   Content-Type    application/json
    ...     Authorization   Bearer ${response_access_token}
    ${randStr}  Generate Random String      6   [LETTERS]
    &{tenant}       Create Dictionary
    ...     tenantId        ${tnt}
    ...     tenantName      MyTenant${randStr}
    ${resp}     POST On Session     multitenancy   /multi-tenant/service
    ...     expected_status=anything   json=&{tenant}   headers=${headers}
    Set Test Variable      ${response}     ${resp}
    Set Test Variable      ${response_code}     ${resp.status_code}
    Should Be Equal As Strings     ${response_code}    ${403}
    #Should Be Equal As Strings      ${resp.json()['error']}     Forbidden
    #Should Be Equal As Strings      ${resp.json()['message']}
    #...         Access Denied because of missing scope:

Create Tenant Without Authorization Bearer
    ${tnt}     Decode JWT And Get TNT Value    ${encoded_token_1}
    Create Session      multitenancy    ${PLUGINURL}    debug=2     verify=True
    ${headers}      Create Dictionary   Content-Type    application/json
    ${randStr}  Generate Random String      6   [LETTERS]
    &{tenant}       Create Dictionary
    ...     tenantId        ${tnt}
    ...     tenantName      MyTenant${randStr}
    ${resp}     POST On Session     multitenancy   /multi-tenant/service
    ...     expected_status=anything   json=&{tenant}   headers=${headers}
    Set Test Variable      ${response}     ${resp}
    Set Test Variable      ${response_code}     ${resp.status_code}
    Should Be Equal As Strings     ${response_code}    ${401}

Create Tenant With Expired Token In Authorization Bearer
    ${tnt}     Decode JWT And Get TNT Value    ${encoded_token_1}
    Create Session      multitenancy    ${PLUGINURL}    debug=2     verify=True
    ${headers}      Create Dictionary   Content-Type    application/json
    ...     Authorization   Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJIOVFvTUtGdHhHOENwazFZc3V5UDlLSDBCYVZaZGxCdDdrVkpXYU5KVE9zIn0.eyJleHAiOjE2NzA1MTU3ODUsImlhdCI6MTY3MDUxNTQ4NSwianRpIjoiOTM4ZTM4MmYtMDIyYi00ZWMyLThjODItZmY4NzVjMzRhMTNlIiwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo4MDgyL2F1dGgvcmVhbG1zL1NhY3JlZCUyMEhlYXJ0IiwiYXVkIjoiYWNjb3VudCIsInN1YiI6ImZjNDJlYTg4LTk1NTgtNDE0Yi1iMzdiLWIyZWE2OTkyMjVhNCIsInR5cCI6IkJlYXJlciIsImF6cCI6IkhJUC1DRFItRUhSYmFzZS1TZXJ2aWNlIiwic2Vzc2lvbl9zdGF0ZSI6IjdiODlhNDU1LWUwOTgtNDcxOS05YjAxLThjMGUyNTBmMzIxOSIsImFjciI6IjEiLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsiZGVmYXVsdC1yb2xlcy1zYWNyZWQgaGVhcnQiLCJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIiwiU3VwZXJBZG1pbiJdfSwicmVzb3VyY2VfYWNjZXNzIjp7ImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSIsInNpZCI6IjdiODlhNDU1LWUwOTgtNDcxOS05YjAxLThjMGUyNTBmMzIxOSIsImVtYWlsX3ZlcmlmaWVkIjpmYWxzZSwicHJlZmVycmVkX3VzZXJuYW1lIjoic3VwZXJhZG1pbkB2aXRhZ3JvdXAuYWciLCJnaXZlbl9uYW1lIjoiIiwiZmFtaWx5X25hbWUiOiIifQ.SRRq4FROBuj6wWWndoupTwvuDflFZIRPdamde2hmp6JFNb5GmQ3efoDv1OKi0fyMh36sGo9blQaPemkgmPDfi8pCs-SN92zLBLraOtDngA19qfc96nN9lGFUybQaWYCxmhEXIkoQTx_cqQ7ixpDx1GrNqFedEnmJueJ-zrqkrSPJDtL55kVSqKQ2mcuqHn38JOpMVELU8R099bhcDJI5fWyMi1MskC5MfCNdifwDkMRuPMNZKQcGN0bYv7osoag57aHcG6yfhA43Rv1MeqTeQ9X4BTXrhzIvYntjPf9pXX-jziWPvF1aPSYMzknMH2dKJSrma657_QwSGXgp9a2pzQ
    ${randStr}  Generate Random String      6   [LETTERS]
    &{tenant}       Create Dictionary
    ...     tenantId        ${tnt}
    ...     tenantName      MyTenant${randStr}
    ${resp}     POST On Session     multitenancy   /multi-tenant/service
    ...     expected_status=anything   json=&{tenant}   headers=${headers}
    Set Test Variable      ${response}     ${resp}
    Set Test Variable      ${response_code}     ${resp.status_code}
    Should Be Equal As Strings     ${response_code}    ${401}

Update Tenant With Valid Authorization Bearer
    ${tnt}     Decode JWT And Get TNT Value    ${encoded_token_1}
    Create Session      multitenancy    ${PLUGINURL}    debug=2     verify=True
    ${headers}      Create Dictionary   Content-Type    application/json
    ...     Authorization   Bearer ${response_access_token}
    ${randStr}  Generate Random String      6   [LETTERS]
    &{tenant}       Create Dictionary
    ...     tenantId        ${tnt}
    ...     tenantName      MyUpdatedTenant${randStr}
    ${resp}     PATCH On Session     multitenancy   /multi-tenant/service
    ...     expected_status=anything   json=&{tenant}   headers=${headers}
    Set Test Variable      ${response}     ${resp}
    Set Test Variable      ${response_code}     ${resp.status_code}
    Should Be Equal As Strings      ${response_code}    ${403}
    #Should Be Equal As Strings      ${resp.json()['error']}     Forbidden
    #Should Be Equal As Strings      ${resp.json()['message']}
    #...         Access Denied because of missing scope:

Update Tenant Without Authorization Bearer
    ${tnt}     Decode JWT And Get TNT Value    ${encoded_token_1}
    Create Session      multitenancy    ${PLUGINURL}    debug=2     verify=True
    ${headers}      Create Dictionary   Content-Type    application/json
    ${randStr}  Generate Random String      6   [LETTERS]
    &{tenant}       Create Dictionary
    ...     tenantId        ${tnt}
    ...     tenantName      MyUpdatedTenant${randStr}
    ${resp}     PATCH On Session     multitenancy   /multi-tenant/service
    ...     expected_status=anything   json=&{tenant}   headers=${headers}
    Set Test Variable      ${response}     ${resp}
    Set Test Variable      ${response_code}     ${resp.status_code}
    Should Be Equal As Strings     ${response_code}    ${401}

Get All Tenants With Valid Authorization Bearer
    Create Session      multitenancy    ${PLUGINURL}    debug=2     verify=True
    ${headers}      Create Dictionary   Content-Type    application/json
    ...     Authorization   Bearer ${response_access_token}
    ${resp}     GET On Session     multitenancy   /multi-tenant/service
    ...     expected_status=anything   headers=${headers}
    Should Be Equal As Strings      ${resp.status_code}     ${403}
    #Should Be Equal As Strings      ${resp.json()['error']}     Forbidden
    #Should Be Equal As Strings      ${resp.json()['message']}
    #...         Access Denied because of missing scope:

Get All Tenants Without Authorization Bearer
    Create Session      multitenancy    ${PLUGINURL}    debug=2     verify=True
    ${headers}      Create Dictionary   Content-Type    application/json
    ${resp}     GET On Session     multitenancy   /multi-tenant/service
    ...     expected_status=anything   headers=${headers}
    Should Be Equal As Strings      ${resp.status_code}     ${401}


*** Keywords ***
Precondition
    Set Credentials For User    ${typeOfUser}
    Obtain Access Token From Keycloak Using User Credentials
    Log     ${response_body}
    Log     ${response_access_token}
    Set Suite Variable      ${response_access_token}