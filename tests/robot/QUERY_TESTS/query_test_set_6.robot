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
Documentation   QUERY Tests from Tests Set 6
...             \nFirst test Setup is creating OPT, EHR and compositions for Tests Set 6
...             \n*POSTCONDITION* Delete all rows from composition, ehr, status, status_history, template_store

Resource        ../_resources/keywords/composition_keywords.robot
Resource        ../_resources/keywords/admin_keywords.robot
Resource        ../_resources/suite_settings.robot
Resource        ../_resources/keywords/aql_query_keywords.robot

Suite Setup         Clean DB
Suite Teardown      Clean DB


*** Variables ***
${optFile}      vitagroup-medication-list.v0.opt
${testSet}      test_set_6


*** Test Cases ***
Query For Medication Values
    [Tags]      807
    [Documentation]     Covers case described in https://github.com/ehrbase/ehrbase/pull/807
    ...     \nCase 2.1 for issue 728
    [Setup]     Prepare Test Set 6 From Query Execution
    ${queryToApply}     Catenate    SELECT i/activities[at0001]/description[at0002]/items[at0070]/value/value as medication
    ...     from EHR e CONTAINS COMPOSITION c CONTAINS INSTRUCTION i [openEHR-EHR-INSTRUCTION.medication_order.v3]
    ...     where c/archetype_details/template_id/value MATCHES {'vitagroup-medication-list.v0'}
    ...     AND e/ehr_id/value='${ehr_id}'
    Set Test Variable   ${queryToSendAndExpected}   ${queryToApply}
    Change Query Select In Request JSON File    q_for_medication.json
    Change Query Select In Expected JSON File   q_for_medication.json
    Execute Query And Compare Actual Result With Expected
    ...     q_for_medication.json
    ...     q_for_medication.json
    ...     test_set=${testSet}

Query For Medication And Dosage Values
    [Tags]      807
    [Documentation]     Covers case described in https://github.com/ehrbase/ehrbase/pull/807
    ...     \nCase 2.2 for issue 728
    ${queryToApply}     Catenate    SELECT i/activities[at0001]/description[at0002]/items[at0070]/value/value as medication,
    ...     i/activities[at0001]/description[at0002]/items[at0009]/value/value as dosage from EHR e
    ...     CONTAINS COMPOSITION c CONTAINS INSTRUCTION i [openEHR-EHR-INSTRUCTION.medication_order.v3]
    ...     where c/archetype_details/template_id/value MATCHES {'vitagroup-medication-list.v0'}
    ...     AND e/ehr_id/value='${ehr_id}'
    Set Test Variable   ${queryToSendAndExpected}   ${queryToApply}
    Change Query Select In Request JSON File    q_for_medication_dosage.json
    Change Query Select In Expected JSON File   q_for_medication_dosage.json
    Execute Query And Compare Actual Result With Expected
    ...     q_for_medication_dosage.json
    ...     q_for_medication_dosage.json
    ...     test_set=${testSet}

Query For Medication Without Instruction
    [Tags]      807
    [Documentation]     Covers case described in https://github.com/ehrbase/ehrbase/pull/807
    ...     \nCase 2.3 for issue 728
    ${queryToApply}     Catenate    SELECT
    ...     c/content[openEHR-EHR-INSTRUCTION.medication_order.v3]/activities[at0001]/description[at0002]/items[at0070]/value/value as medication
    ...     from EHR e CONTAINS COMPOSITION c where c/archetype_details/template_id/value
    ...     MATCHES {'vitagroup-medication-list.v0'} AND e/ehr_id/value='${ehr_id}'
    Set Test Variable   ${queryToSendAndExpected}   ${queryToApply}
    Change Query Select In Request JSON File    q_for_medication_without_instruction.json
    Change Query Select In Expected JSON File   q_for_medication_without_instruction.json
    Execute Query And Compare Actual Result With Expected
    ...     q_for_medication_without_instruction.json
    ...     q_for_medication_without_instruction.json
    ...     test_set=${testSet}


*** Keywords ***
Prepare Test Set 6 From Query Execution
    ${opt_file_name}    Set Variable    vitagroup-medication-list.v0
    Upload OPT    query_test_sets/${optFile}
    prepare new request session    JSON    Prefer=return=representation
    create new EHR with subject_id and default subject id value (JSON)
    check content of created EHR (JSON)
    Commit Composition FLAT And Check Response Status To Be 201
    ...     ${opt_file_name}__composition_with_medication_item.json

Change Query Select In Request JSON File
    [Arguments]     ${testDataFilePath}
    ${initalJson}           Load Json From File     ${ACTUAL JSON TO SEND PAYLOAD}/${testSet}/${testDataFilePath}
    ${returnedJsonFileLocation}     Change EHR ID and Save Back To Request File
    ...     ${initalJson}   ${queryToSendAndExpected}      ${testDataFilePath}

Change Query Select In Expected JSON File
    [Arguments]     ${testDataFilePath}
    ${initalJson}           Load Json From File     ${EXPECTED JSON TO RECEIVE PAYLOAD}/${testSet}/${testDataFilePath}
    ${returnedJsonFileLocation}     Change Query and Save Back To Result File
    ...     ${initalJson}   ${testDataFilePath}

Change EHR ID and Save Back To Request File
    [Documentation]     Updates Query Select value
    ...     using arguments values.
    ...     Takes 3 arguments:
    ...     1 - jsonContent = Loaded Json content
    ...     2 - query to be replaced with new one
    ...     3 - testDataFilePath - File to be changed
     [Arguments]     ${jsonContent}      ${newQueryValue}    ${testDataFilePath}
     ${json_object}      Update Value To Json    json_object=${jsonContent}
    ...             json_path=q     new_value=${queryToSendAndExpected}
    ${json_str}     Convert JSON To String    ${json_object}
    Create File     ${ACTUAL JSON TO SEND PAYLOAD}/${testSet}/${testDataFilePath}    ${json_str}
    [return]    ${ACTUAL JSON TO SEND PAYLOAD}/${testSet}/${testDataFilePath}

Change Query and Save Back To Result File
    [Documentation]     Updates EHR ID value
    ...     in Query result json, using arguments values.
    ...     Takes 3 arguments:
    ...     1 - jsonContent = Loaded Json content
    ...     2 - value to be replaced with New EHR ID
    ...     3 - testDataFilePath - File to be changed
    [Arguments]     ${jsonContent}      ${testDataFilePath}
    ${length}         Get length          ${jsonContent['rows']}
    Log     ${length}
    ${json_object}      Update Value To Json    json_object=${jsonContent}
    ...             json_path=q     new_value=${queryToSendAndExpected}
    ${json_str}     Convert JSON To String    ${json_object}
    Create File     ${EXPECTED JSON TO RECEIVE PAYLOAD}/${testSet}/${testDataFilePath}    ${json_str}
    [return]    ${EXPECTED JSON TO RECEIVE PAYLOAD}/${testSet}/${testDataFilePath}