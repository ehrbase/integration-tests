# Copyright (c) 2020 Wladislaw Wagner (www.trustincode.de) / (Vitasystems GmbH).
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
Metadata    Version    0.1.0
Metadata    Author    *Vladislav Ploaia* CDR Core Team.
Metadata    Created    2020.07.10
Metadata    Updated    2023.01.31

Documentation  Testing authentication with Keycloak OAuth Server

Resource        ../../_resources/suite_settings.robot
Resource        ../../_resources/keywords/ehr_keywords.robot
Resource        ../../_resources/keywords/composition_keywords.robot


*** Variables ***
${expired_token}               eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJSSXc4WUN0MGdVZGtJU2VOSVA3SUhLSVlsMzU5cVBJcWNxb004azBFOU9ZIn0.eyJleHAiOjE2MzY3MzYwMTUsImlhdCI6MTYzNjczNTcxNSwianRpIjoiNTNjNDQ3NTktNTYwNC00ZWNjLWI4NjktNDZlYjg4MjdiZjY3IiwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo4MDgyL2F1dGgvcmVhbG1zL2VocmJhc2UiLCJhdWQiOiJhY2NvdW50Iiwic3ViIjoiYjU4M2RhNjgtOTg5Zi00Mjk3LWE4OWMtYjQzN2M1MjhkZDEzIiwidHlwIjoiQmVhcmVyIiwiYXpwIjoiZWhyYmFzZS1yb2JvdCIsInNlc3Npb25fc3RhdGUiOiIwZjI1NGE5Zi0zMDNiLTQ1MDgtYjE3Ny04NjJmOTlhNjc4NzgiLCJhY3IiOiIxIiwicmVhbG1fYWNjZXNzIjp7InJvbGVzIjpbImVocmJhc2Uub3JnL3VzZXIiLCJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIiwiZWhyYmFzZS5vcmcvYWRtaW5pc3RyYXRvciJdfSwicmVzb3VyY2VfYWNjZXNzIjp7ImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsIm5hbWUiOiJSb2JvdCBGcmFtZXdvcmsiLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJyb2JvdCIsImdpdmVuX25hbWUiOiJSb2JvdCIsImZhbWlseV9uYW1lIjoiRnJhbWV3b3JrIiwiZW1haWwiOiJyb2JvdEBlaHJiYXNlLm9yZyJ9.D1bfUldXErEZEuooyhUNo9jpQAJ9VmZJnejCfFOshcMx573NBUYFHILsU-R-twprct-XuO8TdPW6PyBDeF1SFpFIyq8RhUvNLxjCBUPGas2FxovQ2d_P5pWL86vu7zk0IIm5nSrawqq4UzZ0rwTEP116YsJIHkdG89MVBzolmHkVnFN8ervisLmGy-xxhB_OLeRl-SRdn6oRxH1msVReeKmBv42OKdRLhLkaKefO8Hs_kl8VgE8UdBDwlg40m3S78p-hSmd9vdQ1XPwg2l5bklk0dBJsD_2mBM6Wfq5qnbG-u28oKQ-JmAj0Px_OWa2lLMGut-_Rnv95NAjnmaOV3g

# Client ID and secret come from the 'ehrbase-custom-user' client defined in Keycloak
${client_credentials_grant}    grant_type=client_credentials&client_id=ehrbase-custom-user&client_secret=5d49493b-8bfb-47f9-aa0f-43653370bf6f
#enable below commented var, when KEYCLOAK_URL from sut_config.py will send using KEYCLOAK_URL_FROM_YAML
#${KEYCLOAK_URL}                 http://localhost:8081/auth


*** Test Cases ***
01 Keycloak OAuth server is online
    [Documentation]     Checks that Keycloak server is up and ready.

                    Create Session    keycloak    ${KEYCLOAK_URL}
    ${response}     Get Request    keycloak    /
                    Should Be Equal As Strings 	  ${response.status_code}    200


02 Master realm exists
        REST.GET   ${KEYCLOAK_URL}/realms/master
        Integer    response status   200
        Object     response body
        String     response body public_key


03 Ehrbase realm exists
        REST.GET   ${KEYCLOAK_URL}/realms/ehrbase
        Integer    response status   200
        Object     response body
        String     response body public_key
    

04 Access token with role in realm_access field is retrievable
        # NOTE: ${OAUTH_ACCESS_GRANT} comes from variables file: sut_config.py
        Request Access Token    ${OAUTH_ACCESS_GRANT}
        Status Code    200
        Set Suite Variable    ${password_access_token}    ${response.json()['access_token']}
        Access Token length is greater than    100    ${password_access_token}
        Decode JWT Password Access Token


05 Access token with role in scope field is retrievable
        Request Access Token    ${client_credentials_grant}
        Status Code    200
        Set Suite Variable    ${client_credentials_access_token}    ${response.json()['access_token']}
        Access Token length is greater than    100    ${client_credentials_access_token}
        Decode JWT Client Credentials Access Token


06 Base URL is secured
    [Documentation]     Checks private resource is NOT accessible without auth.
                        Create Session    secured    ${BASEURL}
    ${response}         Get Request    secured    /
                        Should Be Equal As Strings 	  ${response.status_code}    401


07 API endpoints are secured
    [Documentation]     Checks private resources are NOT accessible without auth.
    # EHR /EHR_STATUS
        REST.GET        ${BASEURL}/ehr
        Integer         response status    401

        REST.GET        ${BASEURL}/ehr/123
        Integer         response status    401

        REST.POST       ${BASEURL}/ehr
        Integer         response status    401

        REST.PUT        ${BASEURL}/ehr
        Integer         response status    401

        REST.PUT        ${BASEURL}/ehr/123
        Integer         response status    401

        REST.GET        ${BASEURL}/ehr/123/ehr_status
        Integer         response status    401

        REST.GET        ${BASEURL}/ehr/123/ehr_status/123
        Integer         response status    401

        REST.PUT        ${BASEURL}/ehr/123/ehr_status
        Integer         response status    401

        REST.GET        ${BASEURL}/ehr/123/versioned_ehr_status
        Integer         response status    401

        REST.GET        ${BASEURL}/ehr/123/versioned_ehr_status/revision_history
        Integer         response status    401

        REST.GET        ${BASEURL}/ehr/123/versioned_ehr_status/version
        Integer         response status    401

        REST.GET        ${BASEURL}/ehr/123/versioned_ehr_status/version/123
        Integer         response status    401

    # COMPOSITION
        REST.POST       ${BASEURL}/ehr/123/composition
        Integer         response status    401

        REST.PUT        ${BASEURL}/ehr/123/composition/123
        Integer         response status    401

        REST.DELETE     ${BASEURL}/ehr/123/composition/123
        Integer         response status    401

        REST.GET        ${BASEURL}/ehr/123/composition/123
        Integer         response status    401

        REST.GET        ${BASEURL}/ehr/123/composition/123?version_at_time=111
        Integer         response status    401

        REST.GET        ${BASEURL}/ehr/123/versioned_composition/123
        Integer         response status    401

        REST.GET        ${BASEURL}/ehr/123/versioned_composition/123/revision_history
        Integer         response status    401

        REST.GET        ${BASEURL}/ehr/123/versioned_composition/123/version/123
        Integer         response status    401

        REST.GET        ${BASEURL}/ehr/123/versioned_composition/123/version?version_at_time=222
        Integer         response status    401

    # DIRECTORY
        REST.POST       ${BASEURL}/ehr/123/directory
        Integer         response status    401

        REST.PUT        ${BASEURL}/ehr/123/directory
        Integer         response status    401

        REST.DELETE    ${BASEURL}/ehr/123/directory
        Integer         response status    401

        REST.GET        ${BASEURL}/ehr/123/directory/123
        Integer         response status    401

        REST.GET        ${BASEURL}/ehr/123/directory
        Integer         response status    401

    # CONTRIBUTION
        REST.GET        ${BASEURL}/ehr/123/contribution/123
        Integer         response status    401

        REST.POST       ${BASEURL}/ehr/123/contribution
        Integer         response status    401


08 Private resources are NOT available with invalid/expired token
        Set Headers     { "Authorization": "Bearer ${expired_token}" }
        REST.GET        ${BASEURL}/ehr
                        Output
        Integer         response status    401


09 Private resources are available with valid token when using password grant
        Set Headers     { "Authorization": "Bearer ${password_access_token}" }
        REST.GET        ${BASEURL}/ehr/cd05e77d-63f8-4074-9937-80c4d4406bff
                        Output
        Integer         response status    404


10 Private resources are available with valid token when using client credentials grant
        Set Headers     { "Authorization": "Bearer ${client_credentials_access_token}" }
        REST.GET        ${BASEURL}/ehr/cd05e77d-63f8-4074-9937-80c4d4406bff
                        Output
        Integer         response status    404


# 7) Private resources are available after auth
#    This is tested by reusing existing tests with changed settings on the CI 
#    For details check .circleci/config.yml --> search "SECURITY-test"

Test GET EHR Endpoint Using Password Grant Valid Token
        [Documentation]     Covers: https://jira.vitagroup.ag/browse/CDR-614
        ...     \nCheck that on GET EHR, status code is *200*
        ...     \nand one call with POST request is present in Mock Server,
        ...     with endpoint */rest/v1/policy/execute/name/has_consent_patient*
        ...     \nBody of POST request from Mock Server should contain patient and organization id.
        ...     \npatient and organization id are set in JWT, keyword ObtainPasswordToken.
        ObtainPasswordToken
        Create Session      ${SUT}    ${BASEURL}    debug=2
        Create Headers Dict And Set EHR Headers With Authorization Bearer
        Set To Dictionary   ${headers}
        ...     Authorization=Bearer ${password_access_token}
        Create Mock Sessions
        Create Expectation For POST /rest/v1/policy/execute/name/has_consent_patient
        ${ehr_status_json}  Load JSON From File                     ${VALID EHR DATA SETS}/000_ehr_status.json
        ${payload}          Set EHR Subject Id To Be Patient Id     valid/000_ehr_status.json
        ${resp}     POST On Session     ${SUT}      /ehr
                    ...                 expected_status=anything
                    ...                 headers=${headers}
                    ...                 json=${payload}
                    Should Be Equal As Strings      ${resp.status_code}         ${201}
                    Log     ${resp.json()['ehr_id']['value']}
                    Set Suite Variable      ${ehr_id}           ${resp.json()['ehr_id']['value']}
                    Set Suite Variable      ${ehr_status_id}    ${resp.json()['ehr_status']['uid']['value']}
                    Set Suite Variable      ${ehr_status}       ${resp.json()['ehr_status']}
        ${resp}     Get On Session      ${SUT}      /ehr/${ehr_id}
                    ...                 expected_status=anything
                    ...                 headers=${headers}
                    Should Be Equal As Strings      ${resp.status_code}         ${200}
                    Log     ${resp.json()['ehr_id']['value']}
        Check That Organization And Patient Are Present In Mock Server
        [Teardown]      Run Keywords    Reset Mock Server

Test GET EHR_STATUS Endpoint Using Password Grant Valid Token
        [Documentation]     Covers: https://jira.vitagroup.ag/browse/CDR-614
        ...     \nCheck that on GET ehr_status, status code is *200*
        ...     \nand One call with POST request is present in Mock Server,
        ...     with endpoint */rest/v1/policy/execute/name/has_consent_template*
        ...     \nBody of POST request from Mock Server should contain patient and organization id.
        ...     \npatient and organization id are set in JWT, keyword ObtainPasswordToken.
        Create Headers Dict And Set EHR Headers With Authorization Bearer
        Set To Dictionary   ${headers}
        ...     Authorization=Bearer ${password_access_token}
        Create Expectation For POST /rest/v1/policy/execute/name/has_consent_patient
        ${resp}     Get On Session      ${SUT}      /ehr/${ehr_id}/ehr_status
                    ...                 expected_status=anything
                    ...                 headers=${headers}
                    Should Be Equal As Strings      ${resp.status_code}         ${200}
        Check That Organization And Patient Are Present In Mock Server
        [Teardown]      Reset Mock Server

Test PUT EHR_STATUS Endpoint Using Password Grant Valid Token
        [Documentation]     Covers: https://jira.vitagroup.ag/browse/CDR-614
        ...     \nCheck that on PUT ehr_status, status code is *200*
        ...     \nand One call with POST request is present in Mock Server,
        ...     with endpoint */rest/v1/policy/execute/name/has_consent_template*
        ...     \nBody of POST request from Mock Server should contain patient and organization id.
        ...     \npatient and organization id are set in JWT, keyword ObtainPasswordToken.
        Create Headers Dict And Set EHR Headers With Authorization Bearer
        Set To Dictionary   ${headers}
        ...     Authorization=Bearer ${password_access_token}
        ...     Pefer=return=representation
        ...     If-Match=${ehr_status_id}
        Create Expectation For POST /rest/v1/policy/execute/name/has_consent_patient
        set is_queryable / is_modifiable    is_queryable=${TRUE}
        ${resp}     Put On Session      ${SUT}      /ehr/${ehr_id}/ehr_status   json=${ehr_status}
                    ...                 expected_status=anything
                    ...                 headers=${headers}
                    Should Be Equal As Strings      ${resp.status_code}         ${200}
        Check That Organization And Patient Are Present In Mock Server
        [Teardown]      Reset Mock Server

Test POST Composition Endpoint Using Password Grant Valid Token
        [Documentation]     Covers: https://jira.vitagroup.ag/browse/CDR-614
        ...     \nCheck that on POST Composition, status code is *201*
        ...     \nand One call with POST request is present in Mock Server,
        ...     with endpoint */rest/v1/policy/execute/name/has_consent_template*
        ...     \nBody of POST request from Mock Server should contain patient, organization id and template.
        ...     \npatient, organization id are set in JWT, keyword ObtainPasswordToken, called in first test from suite.
        Upload OPTs
        Set Test Variable       ${template_id}      Corona_Anamnese
        ${file}     Get File    ${COMPO DATA SETS}/CANONICAL_JSON/Corona_Anamnese.json
        Create Headers Dict And Set Composition Headers With Authorization Bearer
        Set To Dictionary       ${headers}
        ...         Authorization=Bearer ${password_access_token}
        Create Expectation For POST /rest/v1/policy/execute/name/has_consent_template
        ${resp}     POST On Session     ${SUT}      /ehr/${ehr_id}/composition
        ...         expected_status=anything        data=${file}    headers=${headers}
                    Should Be Equal As Strings      ${resp.status_code}     ${201}
                    Set Suite Variable      ${full_composition_uid}         ${resp.json()['uid']['value']}
                    ${short_composition_uid}        Remove String           ${full_composition_uid}
                    ...     ::${CREATING_SYSTEM_ID}::1
                    Set Suite Variable      ${composition_uid}         ${short_composition_uid}
        Check That Organization And Patient Are Present In Mock Server
        Check That Template Is Present In Mock Server
        [Teardown]      Reset Mock Server

Test GET VERSIONED_COMPOSITION Endpoint Using Password Grant Valid Token
        [Documentation]     Covers: https://jira.vitagroup.ag/browse/CDR-614
        ...     \nCheck that on GET versioned_composition, status code is *200*
        ...     \nand One call with POST request is present in Mock Server,
        ...     with endpoint */rest/v1/policy/execute/name/has_consent_template*
        ...     \nBody of POST request from Mock Server should contain patient, organization id and template.
        ...     \npatient, organization id are set in JWT, keyword ObtainPasswordToken, called in first test from suite.
        Create Session      ${SUT}    ${BASEURL}    debug=2
        &{headers}          Create Dictionary
        ...     Content-Type=application/json   Accept=application/json
        ...     Prefer=return=representation    Authorization=Bearer ${password_access_token}
        Create Expectation For POST /rest/v1/policy/execute/name/has_consent_template
        ${resp}     GET On Session     ${SUT}
        ...         /ehr/${ehr_id}/versioned_composition/${composition_uid}/version/${full_composition_uid}
        ...         expected_status=anything        headers=${headers}
                    Should Be Equal As Strings      ${resp.status_code}     ${200}
        Check That Organization And Patient Are Present In Mock Server
        Check That Template Is Present In Mock Server
        [Teardown]      Reset Mock Server

Test GET Composition Endpoint Using Password Grant Valid Token
        [Documentation]     Covers: https://jira.vitagroup.ag/browse/CDR-614
        ...     \nCheck that on GET Composition, status code is *200*
        ...     \nand One call with POST request is present in Mock Server,
        ...     with endpoint */rest/v1/policy/execute/name/has_consent_template*
        ...     \nBody of POST request from Mock Server should contain patient, organization id and template.
        ...     \npatient, organization id are set in JWT, keyword ObtainPasswordToken, called in first test from suite.
        Create Session      ${SUT}    ${BASEURL}    debug=2
        &{headers}          Create Dictionary
        ...     Content-Type=application/json   Accept=application/json
        ...     Authorization=Bearer ${password_access_token}
        Create Expectation For POST /rest/v1/policy/execute/name/has_consent_template
        ${resp}     GET On Session     ${SUT}      /ehr/${ehr_id}/composition/${full_composition_uid}
        ...         expected_status=anything        headers=${headers}
                    Should Be Equal As Strings      ${resp.status_code}     ${200}
        Check That Organization And Patient Are Present In Mock Server
        Check That Template Is Present In Mock Server
        [Teardown]      Reset Mock Server

Test DELETE Composition Endpoint Using Password Grant Valid Token
        [Documentation]     Covers: https://jira.vitagroup.ag/browse/CDR-614
        ...     \nCheck that on DELETE Composition, status code is *204*
        ...     \nand One call with POST request is present in Mock Server,
        ...     with endpoint */rest/v1/policy/execute/name/has_consent_template*
        ...     \nBody of POST request from Mock Server should contain patient, organization id and template.
        ...     \npatient, organization id are set in JWT, keyword ObtainPasswordToken, called in first test from suite.
        Create Session      ${SUT}    ${BASEURL}    debug=2
        &{headers}          Create Dictionary
        ...     Content-Type=application/json   Accept=application/json
        ...     Prefer=return=representation    Authorization=Bearer ${password_access_token}
        Create Expectation For POST /rest/v1/policy/execute/name/has_consent_template
        ${resp}     DELETE On Session     ${SUT}      /ehr/${ehr_id}/composition/${full_composition_uid}
        ...         expected_status=anything        headers=${headers}
                    Should Be Equal As Strings      ${resp.status_code}     ${204}
        Check That Organization And Patient Are Present In Mock Server
        Check That Template Is Present In Mock Server
        [Teardown]      Reset Mock Server

Test GET (Deleted) Composition Endpoint Using Password Grant Valid Token
        [Documentation]     Covers: https://jira.vitagroup.ag/browse/CDR-614
        ...     \nCheck that on GET (deleted) Composition, status code is *204*
        ...     \nand One call with POST request is present in Mock Server,
        ...     with endpoint */rest/v1/policy/execute/name/has_consent_template*
        ...     \nBody of POST request from Mock Server should contain patient, organization id and template.
        ...     \npatient, organization id are set in JWT, keyword ObtainPasswordToken, called in first test from suite.
        Create Session      ${SUT}    ${BASEURL}    debug=2
        &{headers}          Create Dictionary
        ...     Content-Type=application/json   Accept=application/json
        ...     Authorization=Bearer ${password_access_token}
        Create Expectation For POST /rest/v1/policy/execute/name/has_consent_template
        ${resp}     GET On Session     ${SUT}      /ehr/${ehr_id}/composition/${full_composition_uid}
        ...         expected_status=anything        headers=${headers}
                    Should Be Equal As Strings      ${resp.status_code}     ${204}
        Check That Organization And Patient Are Present In Mock Server
        Check That Template Is Present In Mock Server
        [Teardown]      Reset Mock Server

Test POST Contribution Endpoint Using Password Grant Valid Token
        [Documentation]     Covers: https://jira.vitagroup.ag/browse/CDR-614
        ...     \nCheck that on POST Contribution, status code is *201*
        ...     \nand One call with POST request is present in Mock Server,
        ...     with endpoint */rest/v1/policy/execute/name/has_consent_template*
        ...     \nBody of POST request from Mock Server should contain patient, organization id and template.
        ...     \npatient, organization id are set in JWT, keyword ObtainPasswordToken, called in first test from suite
        Create Session      ${SUT}    ${BASEURL}    debug=2
        &{headers}          Create Dictionary
        ...     Content-Type=application/json   Accept=application/json
        ...     Prefer=return=representation    Authorization=Bearer ${password_access_token}
        Create Expectation For POST /rest/v1/policy/execute/name/has_consent_template
        ${file}     Load JSON From File
        ...     ${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/contributions/valid/minimal/minimal_evaluation.contribution.json
        ${resp}     POST On Session     ${SUT}      /ehr/${ehr_id}/contribution     expected_status=anything
                    ...     json=${file}
                    ...     headers=${headers}
                    Should Be Equal As Strings      ${resp.status_code}     ${201}
                    Log     Contribution ID: ${resp.json()['uid']['value']}
        Check That Organization And Patient Are Present In Mock Server
        Check That Template Is Present In Mock Server
        [Teardown]      Reset Mock Server

Test POST Query Endpoint Using Password Grant Valid Token
        [Documentation]     Covers: https://jira.vitagroup.ag/browse/CDR-614
        ...     \nCheck that on POST Query, status code is *200*
        ...     \nand One call with POST request is present in Mock Server,
        ...     with endpoint */rest/v1/policy/execute/name/has_consent_template*
        ...     \nBody of POST request from Mock Server should contain patient, organization id and template.
        ...     \npatient, organization id are set in JWT, keyword ObtainPasswordToken, called in first test from suite.
        Create Session      ${SUT}    ${BASEURL}    debug=2
        &{headers}          Create Dictionary
        ...     Content-Type=application/json   Accept=application/json
        ...     Prefer=return=representation    Authorization=Bearer ${password_access_token}
        Create Expectation For POST /rest/v1/policy/execute/name/has_consent_template
        ${query}    Catenate
        ...         SELECT
        ...         e/ehr_id/value, c/uid/value, c/archetype_details/template_id/value, c/feeder_audit
        ...         FROM EHR e
        ...         CONTAINS composition c
        Set Test Variable    ${payload}    {"q": "${query}"}
        ${resp}     POST On Session     ${SUT}      /query/aql     expected_status=anything
                    ...     data=${payload}
                    ...     headers=${headers}
                    Should Be Equal As Strings      ${resp.status_code}     ${200}
        Check That Organization And Patient Are Present In Mock Server
        Check That Template Is Present In Mock Server
        [Teardown]      Reset Mock Server

Test GET Query Endpoint Using Password Grant Valid Token
        [Documentation]     Covers: https://jira.vitagroup.ag/browse/CDR-614
        ...     \nCheck that on GET Query, status code is *200*
        ...     \nand One call with POST request is present in Mock Server,
        ...     with endpoint */rest/v1/policy/execute/name/has_consent_template*
        ...     \nBody of POST request from Mock Server should contain patient, organization id and template.
        ...     \npatient, organization id are set in JWT, keyword ObtainPasswordToken, called in first test from suite
        Create Session      ${SUT}    ${BASEURL}    debug=2
        &{headers}          Create Dictionary
        ...     Content-Type=application/json   Accept=application/json
        ...     Prefer=return=representation    Authorization=Bearer ${password_access_token}
        Create Expectation For POST /rest/v1/policy/execute/name/has_consent_template
        ${query}    Catenate
        ...         SELECT
        ...         e/ehr_id/value, c/uid/value, c/archetype_details/template_id/value, c/feeder_audit
        ...         FROM EHR e
        ...         CONTAINS composition c
        ${resp}     GET On Session     ${SUT}      /query/aql     expected_status=anything
                    ...     params=q=${query}
                    ...     headers=${headers}
                    Should Be Equal As Strings      ${resp.status_code}     ${200}
        Check That Organization And Patient Are Present In Mock Server
        Check That Template Is Present In Mock Server
        [Teardown]      Reset Mock Server

Test GET Query With Multiple EHRs And Templates Using Password Grant Valid Token
        [Documentation]     Covers: https://jira.vitagroup.ag/browse/CDR-614
        ...     \nCheck that on POST Composition, status code is *201*.
        ...     \nCheck that on GET Query, status code is *200*.
        ...     \nand Two calls with POST request are present in Mock Server (for POST Composition and GET Query),
        ...     \nwith endpoint */rest/v1/policy/execute/name/has_consent_template*
        ...     \nBody of POST request from Mock Server should contain patient, organization id and template.
        ...     \npatient, organization id are set in JWT, keyword ObtainPasswordToken, called in first test from suite
        Set Test Variable       ${template_id}      minimal_evaluation.en.v1
        ${file}     Get File    ${COMPO DATA SETS}/CANONICAL_JSON/minimal_evaluation.en.v1__.json
        Create Headers Dict And Set Composition Headers With Authorization Bearer
        Set To Dictionary       ${headers}
        ...         Authorization=Bearer ${password_access_token}
        Create Expectation For POST /rest/v1/policy/execute/name/has_consent_template
        ${resp}     POST On Session     ${SUT}      /ehr/${ehr_id}/composition
        ...         expected_status=anything        data=${file}    headers=${headers}
                    Should Be Equal As Strings      ${resp.status_code}     ${201}
                    Set Suite Variable      ${full_composition_uid}         ${resp.json()['uid']['value']}
                    ${short_composition_uid}        Remove String           ${full_composition_uid}
                    ...     ::${CREATING_SYSTEM_ID}::1
                    Set Suite Variable      ${composition_uid}         ${short_composition_uid}
        Check That Organization And Patient Are Present In Mock Server
        Check That Template Is Present In Mock Server
        ########################################
        Reset Mock Server
        Create Expectation For POST /rest/v1/policy/execute/name/has_consent_template
        ${query}    Catenate
        ...         SELECT
        ...         e/ehr_id/value, c/uid/value, c/archetype_details/template_id/value, c/feeder_audit
        ...         FROM EHR e
        ...         CONTAINS composition c
        ${resp}     GET On Session     ${SUT}      /query/aql     expected_status=anything
                    ...     params=q=${query}
                    ...     headers=${headers}
                    Should Be Equal As Strings      ${resp.status_code}     ${200}
        Check That Organization And Patient Are Present In Mock Server
        Check That Template Is Present In Mock Server
        [Teardown]      Reset Mock Server


*** Keywords ***
Request Access Token
    [Arguments]         ${grant}
                        Create Session    keycloak   ${KEYCLOAK_URL}   verify=${False}    debug=3
    &{headers}=         Create Dictionary    Content-Type=application/x-www-form-urlencoded
    ${resp}=            POST On Session    keycloak   /realms/ehrbase/protocol/openid-connect/token   expected_status=anything
                        ...             data=${grant}   headers=${headers}
                        Set Test Variable    ${response}    ${resp}

Status Code
    [Arguments]         ${expected}
                        Should Be Equal As Strings 	${response.status_code}    ${expected}

Access Token length is greater than
    [Arguments]         ${expected}    ${token}
    ${length} = 	    Get Length   ${token}
                        Should be true     ${length} > ${expected}

Decode JWT Password Access Token
    &{decoded_token}=   decode token      ${password_access_token}
                        Log To Console    \nNAME: ${decoded_token.name}
                        Log To Console    EMAIL: ${decoded_token.email}
                        Log To Console    USERNAME: ${decoded_token.preferred_username}
                        Log To Console    CLIENT: ${decoded_token.azp}
                        Log To Console    ROLES: ${decoded_token.realm_access.roles}
                        Log To Console    \nDECODED TOKEN: ${decoded_token}
                        Dictionary Should Contain Item    ${decoded_token}    typ   Bearer

Decode JWT Client Credentials Access Token
    &{decoded_token}=   decode token      ${client_credentials_access_token}
                        Log To Console    \nCLIENT: ${decoded_token.azp}
                        Log To Console    \nSCOPE: ${decoded_token.scope}
                        Log To Console    \nDECODED TOKEN: ${decoded_token}
                        Dictionary Should Contain Item    ${decoded_token}    typ   Bearer

Create Headers Dict And Set EHR Headers With Authorization Bearer
    &{headers}          Create Dictionary     &{EMPTY}
    Set To Dictionary   ${headers}
    ...     content=application/json     accept=application/json      Prefer=return=representation
    Set Test Variable       ${headers}      ${headers}

Create Headers Dict And Set Composition Headers With Authorization Bearer
    &{headers}          Create Dictionary     &{EMPTY}
    Set To Dictionary   ${headers}
    ...     Content-Type=application/json   Accept=application/json
    ...     Prefer=return=representation    openEHR-VERSION.lifecycle_state=complete
    Set Test Variable       ${headers}      ${headers}

ObtainPasswordToken
    Request Access Token    ${OAUTH_ACCESS_GRANT}
    Status Code    200
    Set Suite Variable    ${password_access_token}    ${response.json()['access_token']}
    Access Token length is greater than    100    ${password_access_token}
    &{decoded_token}=   decode token      ${password_access_token}
    Dictionary Should Contain Item    ${decoded_token}    typ   Bearer
    Set Suite Variable      ${email}    ${decoded_token.email}
    Set Suite Variable      ${sub}      ${decoded_token.sub}
    Set Suite Variable      ${organization_id}      ${decoded_token.organization_id}
    Set Suite Variable      ${patient_id}           ${decoded_token.patient_id}
    Log To Console    \nDECODED TOKEN: ${decoded_token}

Create Mock Sessions
    Create Session          server      ${MOCK_URL}
    Create Mock Session     ${MOCK_URL}

Reset Mock Server
    Dump To Log
    Reset All Requests

Create Expectation For POST /rest/v1/policy/execute/name/has_consent_patient
    &{req}      Create Mock Request Matcher     POST
    ...         /rest/v1/policy/execute/name/has_consent_patient   #body=${body}
    &{rsp}      Create Mock Response
    ...     status_code=200     #body=${body}
    Create Mock Expectation     ${req}      ${rsp}

Create Expectation For POST /rest/v1/policy/execute/name/has_consent_template
    &{req}      Create Mock Request Matcher     POST
    ...         /rest/v1/policy/execute/name/has_consent_template
    &{rsp}      Create Mock Response
    ...     status_code=200
    Create Mock Expectation     ${req}      ${rsp}

Check That Organization And Patient Are Present In Mock Server
    [Documentation]     Verify if Organization and Patient values are present in mock server
    ...         - url address of mock server with endpoint -> http://localhost:1080/path
    ...         Depends on ObtainPasswordToken keyword, as there are set {organization_id}, {patient_id}
    ${mockResp}         PUT on session      server      /mockserver/retrieve
    Should Be Equal As Strings      ${mockResp.status_code}     ${200}
    ${countRequests}    Get Length  ${mockResp.json()}
    Length Should Be    ${mockResp.json()}      1
    IF  ${countRequests} > 0
        FOR     ${el}   IN     @{mockResp.json()}
            ${orgIsFound}     Run Keyword And Return Status
            ...     Should Be Equal As Strings      ${el["body"]["organization"]}   ${organization_id}
            ${patIsFound}     Run Keyword And Return Status
            ...     Should Be Equal As Strings      ${el["body"]["patient"]}        ${patient_id}
            Return From Keyword If      '${orgIsFound}' == '${TRUE}'    and     '${patIsFound}' == '${TRUE}'
        END
    ELSE
        Fail    No requests found or no such Organzation or no such Patient found in Mock Server.
    END

Check That Template Is Present In Mock Server
    [Documentation]     Verify if Template value is present in mock server
    ...         - url address of mock server with endpoint -> http://localhost:1080/path
    ...         - {template_id} is set at test level
    ${mockResp}         PUT on session      server      /mockserver/retrieve
    Should Be Equal As Strings      ${mockResp.status_code}     ${200}
    ${countRequests}    Get Length  ${mockResp.json()}
    Length Should Be    ${mockResp.json()}      1
    IF  ${countRequests} > 0
        FOR     ${el}   IN     @{mockResp.json()}
            ${templateIsFound}     Run Keyword And Return Status
            ...     Should Be Equal As Strings      ${el["body"]["template"]}   ${template_id}
            Return From Keyword If      '${templateIsFound}' == '${TRUE}'
        END
    ELSE
        Fail    No requests or template found in Mock Server.
    END

Set EHR Subject Id To Be Patient Id
    [Arguments]         ${test_data_set}
    ${subject_id}=      Set Variable    ${patient_id}
    ${body}=            Load JSON From File    ${EXECDIR}/robot/_resources/test_data_sets/ehr/${test_data_set}
    ${body}=            Update Value To Json    ${body}  $..subject.external_ref.id.value  ${subject_id}
    [RETURN]            ${body}

generate random id
    ${uuid}=            Set Variable    ${{str(uuid.uuid4())}}
    [RETURN]            ${uuid}

Upload OPTs
    Upload OPT    all_types/Corona_Anamnese.opt
    Upload OPT    minimal/minimal_evaluation.opt