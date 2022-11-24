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
Documentation   CORS integration test suite
Metadata        TOP_TEST_SUITE    CORS_TESTS

Resource    ${EXECDIR}/robot/_resources/suite_settings.robot


*** Variables ***
${SUT}          TEST


*** Test Cases ***
Test CORS Basic Auth
    [Documentation]     Test case to cover CORs with Basic Auth
    ...     \nOpen EHR Server is started with:
    ...     - security.authType=BASIC
    ...     - spring.cache.type=SIMPLE
    ...     \nMethod: GET
    ...     \nEndpoint: /rest/openehr/v1/definition/template/adl1.4
    ...     \nHeaders:
    ...     - Access-Control-Request-Method: GET
    ...     - Origin: https://client.ehrbase.org
    ...     \n*Expected status code = 200*
    ...     \nPostcondition: Shutdown SUT
    set test variable    ${SECURITY_AUTHTYPE}       BASIC
    set test variable    ${SPRING_CACHE_TYPE}       SIMPLE
    startup SUT
    Create New Session And Perform Get Template
    Should Be Equal As Strings    ${response.status_code}    200
    [Teardown]  shutdown SUT

Test CORS No Auth
    [Documentation]     Test case to cover CORs with No Auth
    ...     \nOpen EHR Server is started with:
    ...     - security.authType={None}
    ...     - spring.cache.type=SIMPLE
    ...     \nMethod: GET
    ...     \nEndpoint: /rest/openehr/v1/definition/template/adl1.4
    ...     \nHeaders:
    ...     - Access-Control-Request-Method: GET
    ...     - Origin: https://client.ehrbase.org
    ...     \n*Expected status code = 200*
    ...     \nPostcondition: Shutdown SUT
    set test variable    ${SECURITY_AUTHTYPE}       ${None}
    set test variable    ${SPRING_CACHE_TYPE}       SIMPLE
    startup SUT
    Create New Session And Perform Get Template
    Should Be Equal As Strings    ${response.status_code}    200
    [Teardown]  shutdown SUT


*** Keywords ***
Create New Session And Perform Get Template
    [Documentation]     Create new session and perform Get template API call
    Create Session      ${SUT}    ${BASEURL}    debug=2
        ...             auth=${CREDENTIALS}     verify=True
    &{headers}          Create Dictionary
        ...     Access-Control-Request-Method=GET
        ...     Origin=https://client.ehrbase.org
    ${resp}             Get On Session    ${SUT}    /definition/template/adl1.4
        ...     expected_status=anything
        ...     headers=${headers}
    Set Test Variable   ${response}     ${resp}