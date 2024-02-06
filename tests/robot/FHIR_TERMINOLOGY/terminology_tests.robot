# Copyright (c) 2024 Vladislav Ploaia (Vitagroup - CDR Core Team).
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
Documentation   FHIR TERMINOLOGY TESTS
...             Covers https://vitagroup-ag.atlassian.net/browse/CDR-1136
...             \n*Precondition* Upload OPT and Create EHR
...             \n*Postcondition* called in last test -> Delete EHR
...             README to start docker services: https://github.com/ehrbase/fhir-terminology-server/tree/feature/docker-compose-setup

Resource        ../_resources/keywords/composition_keywords.robot
Resource        ../_resources/keywords/contribution_keywords.robot
Resource        ../_resources/keywords/admin_keywords.robot
Resource        ../_resources/keywords/ehr_keywords.robot

Suite Setup       Precondition


*** Variables ***
${non_existing_err_msg}     The value non-existing-code-string does not match any option from value set


*** Test Cases ***
1. Create Composition - Existing ValueSet Value
    [Tags]      Positive
    [Documentation]     Create Composition with ValueSet value 'D' present in http://terminology.hl7.org/ValueSet/surface
    ...                 \nExpect 201 status code
    commit composition   format=CANONICAL_JSON
    ...                  composition=teminology_test.ehrbase.org.v1__valid.json
    check the successful result of commit composition

2. Create Composition - Non Existing ValueSet Value
    [Tags]      Negative
    [Documentation]     Create Composition with ValueSet value 'non-existing-code-string' not present in http://terminology.hl7.org/ValueSet/surface
    ...                 \nExpect 422 status code
    ...                 \nError message to contain: ${non_existing_err_msg}
    commit composition   format=CANONICAL_JSON
    ...                  composition=teminology_test.ehrbase.org.v1__invalid.json
    Expect Status Code And Error Message
    ...     response=${response}    status_code=${422}    error_message=${non_existing_err_msg}

3. Create Contribution - Existing ValueSet Value
    [Tags]      Positive
    [Documentation]     Create Contribution where Composition contains ValueSet value 'MO' present in http://terminology.hl7.org/ValueSet/surface
    ...                 \nExpect 201 status code
    commit CONTRIBUTION (JSON)      minimal/contribution.create_composition.teminology_test_valid_valueset.json
    Should Be Equal     ${response.status_code}     ${201}

4. Create Contribution - Non Existing ValueSet Value
    [Tags]      Negative
    [Documentation]     Create Contribution where Composition contains ValueSet value 'non-existing-code-string' not present in http://terminology.hl7.org/ValueSet/surface
    ...                 \nExpect 400 status code
    ...                 \nError message to contain: ${non_existing_err_msg}
    Run Keyword And Expect Error    *
    ...     commit CONTRIBUTION (JSON)      minimal/contribution.create_composition.teminology_test_invalid_valueset.json
    Expect Status Code And Error Message
    ...     response=${response}    status_code=${400}    error_message=${non_existing_err_msg}

5. Update Composition - With Another Existing ValueSet Value
    [Tags]      Positive
    [Documentation]     Update Composition with ValueSet value 'DI' present in http://terminology.hl7.org/ValueSet/surface
    ...                 \nExpect 200 status code.
    ...                 \nInitially created composition has code_string="D"
    commit composition   format=CANONICAL_JSON
    ...                  composition=teminology_test.ehrbase.org.v1__valid.json
    check the successful result of commit composition
    Set Test Variable    ${composition_uid}     ${compositionUid}
    update composition (JSON)    teminology_test.ehrbase.org.v1__valid_v2.json     file_type=json
    Should Be Equal     ${response.status_code}     ${200}
    Should Contain      ${composition_uid_v2}   ::2

6. Update Composition - With Non Existing ValueSet Value
    [Tags]      Negative
    [Documentation]     Update Composition with ValueSet value 'non-existing-code-string' not present in http://terminology.hl7.org/ValueSet/surface
    ...                 \nExpect 422 status code.
    ...                 \nInitially created composition has code_string="D"
    ...                 \nError message to contain: ${non_existing_err_msg}
    commit composition   format=CANONICAL_JSON
    ...                  composition=teminology_test.ehrbase.org.v1__valid.json
    check the successful result of commit composition
    Set Test Variable    ${composition_uid}     ${compositionUid}
    Run Keyword And Expect Error    *
    ...     update composition (JSON)    teminology_test.ehrbase.org.v1__invalid.json     file_type=json
    Expect Status Code And Error Message
    ...     response=${response}    status_code=${422}    error_message=${non_existing_err_msg}
    [Teardown]      (admin) delete ehr


*** Keywords ***
Precondition
    Upload OPT    all_types/teminology_test.ehrbase.org.v1.opt
    create EHR

Expect Status Code And Error Message
    [Arguments]     ${response}      ${status_code}     ${error_message}
    Should Be Equal     ${response.status_code}     ${status_code}
    Should Contain      ${response.json()["message"]}
    ...     ${error_message}