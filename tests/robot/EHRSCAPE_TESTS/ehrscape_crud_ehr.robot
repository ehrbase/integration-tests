# Copyright (c) 2019 Wladislaw Wagner (Vitasystems GmbH), Pablo Pazos (Hannover Medical School),
# Nataliya Flusman (Solit Clouds), Nikita Danilin (Solit Clouds)
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
# Author: Vladislav Ploaia


*** Settings ***
Documentation       EHRScape Tests
...                 Documentation URL to be defined

Resource            ../_resources/keywords/composition_keywords.robot
Resource            ../_resources/keywords/ehr_keywords.robot
Resource            ../_resources/keywords/admin_keywords.robot

Suite Setup         Set Library Search Order For Tests
#Suite Teardown      restart SUT


*** Test Cases ***
Main Flow Create EHR
    [Documentation]     Create EHR using EHRScape endpoint.
    [Tags]    PostEhr    EHRSCAPE
    Upload OPT    all_types/ehrn_family_history.opt
    Extract Template Id From OPT File
    Get Web Template By Template Id (ECIS)    ${template_id}
    Create EHR With EHR Status
    Set Suite Variable      ${subject_id}           ${response.json()["ehr_status"]["subject"]["external_ref"]["id"]["value"]}
    Set Suite Variable      ${subject_namespace}    ${response.json()["ehr_status"]["subject"]["external_ref"]["namespace"]}
    ${externalTemplate}    Set Variable    ${template_id}
    Set Test Variable       ${externalTemplate}

Get EHR Using Ehr Id And By Subject Id, Namespace
    [Documentation]    1. Get existing EHR using Ehr Id.
    ...     2. Get existing EHR using Subject Id and Subject Namespace criteria.
    ...     *Dependency*: Test Case -> Main Flow Create EHR, ehr_id suite variable.
    [Tags]    GetEhr    EHRSCAPE
    retrieve EHR by ehr_id
    retrieve EHR by subject_id      subject_namespace=${subject_namespace}
    [Teardown]      (admin) delete ehr

#Update EHR Status
#    [Documentation]    Create EHR, Get it and update EHR status.
#    [Tags]    UpdateEhrStatus   EHRSCAPE
#    ${ehr_status_json}      Load JSON From File
#                            ...     ${VALID EHR DATA SETS}/000_ehr_status_ecis.json
#    update EHR: set ehr-status modifiable    ${TRUE}
#    Update EHR Status (ECIS)    ${ehr_id}   ${ehr_status_json}
#    Should Be Equal As Strings  ${response["body"]["action"]}    UPDATE
#    Should Be Equal             ${response["body"]["ehrStatus"]["modifiable"]}          ${True}
#    Should Be Equal             ${response["body"]["ehrStatus"]["queryable"]}           ${True}
#    Should Be Equal As Strings  ${response["body"]["ehrStatus"]["subjectId"]}           74777-1258
#    Should Be Equal As Strings  ${response["body"]["ehrStatus"]["subjectNamespace"]}    testIssuerModified


*** Keywords ***
Create EHR With EHR Status
    [Documentation]     Create EHR with EHR_Status and other details, so it can contain correct subject object.
    prepare new request session     JSON
    create new EHR with ehr_status  ${VALID EHR DATA SETS}/000_ehr_status_with_other_details.json