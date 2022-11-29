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
Documentation   QUERY Tests from Tests Set 1
...             \nFirst test Setup is creating OPT, EHR and compositions for Tests Set 1
...             \n*POSTCONDITION* Delete all rows from composition, ehr, status, status_history, template_store

Resource        ../_resources/keywords/composition_keywords.robot
Resource        ../_resources/keywords/admin_keywords.robot
Resource        ../_resources/suite_settings.robot
Resource        ../_resources/keywords/aql_query_keywords.robot

Suite Setup         Clean DB
Suite Teardown      Clean DB


*** Variables ***
${optFile}      ehrbase.testcase05.v0.opt
${testSet}      test_set_1


*** Test Cases ***
Query For EHRs
    [Setup]     Prepare Test Set 1 From Query Execution
    Execute Query And Compare Actual Result With Expected
    ...     q_ehrs.json
    ...     q_ehrs.json
    ...     test_set=${testSet}

Query For Compositions
    Execute Query And Compare Actual Result With Expected
    ...     q_for_compositions.json
    ...     q_for_compositions.json
    ...     test_set=${testSet}

Query For Observation
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_observation.json
    ...     q_for_observation.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-555

Query For Observation[x]
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_observation_x.json
    ...     q_for_observation_x.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-555

Query For Action
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_action.json
    ...     q_for_action.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-555

Query For Action[x]
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_action_x.json
    ...     q_for_action_x.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-555

Query For Evaluation
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_evaluation.json
    ...     q_for_evaluation.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-555

Query For Evaluation[x]
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_evaluation_x.json
    ...     q_for_evaluation_x.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-555

Query For Instruction
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_instruction.json
    ...     q_for_instruction.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-555

Query For Instruction[x]
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_instruction_x.json
    ...     q_for_instruction_x.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-555

Query For Admin
    Execute Query And Compare Actual Result With Expected
    ...     q_for_admin.json
    ...     q_for_admin.json
    ...     test_set=${testSet}

Query For Admin[x]
    Execute Query And Compare Actual Result With Expected
    ...     q_for_admin_x.json
    ...     q_for_admin_x.json
    ...     test_set=${testSet}

Query For Cluster
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_cluster.json
    ...     q_for_cluster.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-555

Query For Cluster[x]
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_cluster_x.json
    ...     q_for_cluster_x.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-555

Query For Composition > Observation
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_composition_observation.json
    ...     q_for_composition_observation.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-555

Query For Composition[x] > Observation
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_composition_x_observation.json
    ...     q_for_composition_x_observation.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-555

Query For Composition[x] > Observation[x]
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_composition_x_observation_x.json
    ...     q_for_composition_x_observation_x.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-555

Query For Composition > Action
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_composition_action.json
    ...     q_for_composition_action.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-555

Query For Composition[x] > Action
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_composition_x_action.json
    ...     q_for_composition_x_action.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-555

Query For Composition[x] > Action[x]
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_composition_x_action_x.json
    ...     q_for_composition_x_action_x.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-555

Query For Composition > Evaluation
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_composition_evaluation.json
    ...     q_for_composition_evaluation.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-555

Query For Composition[x] > Evaluation
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_composition_x_evaluation.json
    ...     q_for_composition_x_evaluation.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-555

Query For Composition[x] > Evaluation[x]
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_composition_x_evaluation_x.json
    ...     q_for_composition_x_evaluation_x.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-555

Query For Composition > Instruction
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_composition_instruction.json
    ...     q_for_composition_instruction.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-555

Query For Composition[x] > Instruction
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_composition_x_instruction.json
    ...     q_for_composition_x_instruction.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-555

Query For Composition[x] > Instruction [x]
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_composition_x_instruction_x.json
    ...     q_for_composition_x_instruction_x.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-555

Query For Composition > Admin
    Execute Query And Compare Actual Result With Expected
    ...     q_for_composition_admin.json
    ...     q_for_composition_admin.json
    ...     test_set=${testSet}

Query For Composition [x] > Admin
    Execute Query And Compare Actual Result With Expected
    ...     q_for_composition_x_admin.json
    ...     q_for_composition_x_admin.json
    ...     test_set=${testSet}

Query For Composition [x] > Admin [x]
    Execute Query And Compare Actual Result With Expected
    ...     q_for_composition_x_admin_x.json
    ...     q_for_composition_x_admin_x.json
    ...     test_set=${testSet}

Query For CDR-631
    [Tags]      CDR-631
    [Documentation]     Covers case described in JIRA ticket CDR-631
    ...     \nhttps://jira.vitagroup.ag/browse/CDR-631
    ...     \nRobot script for https://github.com/ehrbase/openEHR_SDK/blob/develop/client/src/test/java/org/ehrbase/client/openehrclient/defaultrestclient/AqlTestIT.java
    ...     \ntestExecute10()
    ${queryToApply}     Catenate    select e/ehr_id/value,
    ...     o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude as systolic
    ...     from EHR e[ehr_id/value = '${ehr_id}'] contains Observation o
    ...     where o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude = 130.0
    Log     ${ehr_id}
    Set Test Variable   ${queryToSendAndExpected}   ${queryToApply}
    Change Query Select In Request JSON File    q_for_cdr_631.json
    Change EHR ID In Expected JSON File     q_for_cdr_631.json
    Execute Query And Compare Actual Result With Expected
    ...     q_for_cdr_631.json
    ...     q_for_cdr_631.json
    ...     test_set=${testSet}

Query For Like Operator - % Wildcard At The Beginning
    [Tags]      CDR-517
    [Documentation]     Covers case described in JIRA ticket CDR-631
    ...     \nLike operator is used to get results where '%string'
    ...     \nhttps://jira.vitagroup.ag/browse/CDR-517
    Execute Query And Compare Actual Result With Expected
    ...     q_for_wildcard_begin_string.json
    ...     q_for_wildcard_begin_string.json
    ...     test_set=${testSet}

Query For Like Operator - % Wildcard At The End
    [Tags]      CDR-517
    [Documentation]     Covers case described in JIRA ticket CDR-631
    ...     \nLike operator is used to get results where 'string%'
    ...     \nhttps://jira.vitagroup.ag/browse/CDR-517
    Execute Query And Compare Actual Result With Expected
    ...     q_for_wildcard_end_string.json
    ...     q_for_wildcard_end_string.json
    ...     test_set=${testSet}

Query For Like Operator - % Wildcard At The Start And End
    [Tags]      CDR-517
    [Documentation]     Covers case described in JIRA ticket CDR-631
    ...     \nLike operator is used to get results where '%string%'
    ...     \nhttps://jira.vitagroup.ag/browse/CDR-517
    Execute Query And Compare Actual Result With Expected
    ...     q_for_wildcard_start_end_string.json
    ...     q_for_wildcard_start_end_string.json
    ...     test_set=${testSet}

#Query For Medication Values
#    [Tags]      807
#    [Documentation]     Covers case described in https://github.com/ehrbase/ehrbase/pull/807
#    ...     \nCase 2.1 for issue 728
#    ${queryToApply}     Catenate    select e/ehr_id/value,
#    ...     from EHR e[ehr_id/value = '${ehr_id}'] contains Observation o
#    ...     SELECT i/activities[at0001]/description[at0002]/items[at0070]/value/value as medication
#    ...     from EHR e CONTAINS COMPOSITION c CONTAINS INSTRUCTION i [openEHR-EHR-INSTRUCTION.medication_order.v3]
#    ...     where c/archetype_details/template_id/value MATCHES {'vitagroup-medication-list.v0'}
#    ...     AND e/ehr_id/value='${ehr_id}'
#    Execute Query And Compare Actual Result With Expected
#    ...     q_for_medication.json
#    ...     q_for_medication.json
#    ...     test_set=${testSet}
#    Set Test Variable   ${queryToSendAndExpected}   ${queryToApply}
#    Change Query Select In Request JSON File    q_for_medication.json


*** Keywords ***
Prepare Test Set 1 From Query Execution
    ${opt_file_name}    Set Variable    ehrbase.testcase05.v0
    Upload OPT    query_test_sets/${optFile}
    prepare new request session    JSON    Prefer=return=representation
    create new EHR with subject_id and default subject id value (JSON)
    check content of created EHR (JSON)
    Commit Composition FLAT And Check Response Status To Be 201
    ...     ${opt_file_name}__compo1_test_set_1.json
    Commit Composition FLAT And Check Response Status To Be 201
    ...     ${opt_file_name}__compo2_test_set_1.json    #130.0
    Commit Composition FLAT And Check Response Status To Be 201
    ...     ${opt_file_name}__compo3_no_obs_test_set_1.json
    Commit Composition FLAT And Check Response Status To Be 201
    ...     ${opt_file_name}__compo4_no_action_test_set_1.json
    Commit Composition FLAT And Check Response Status To Be 201
    ...     ${opt_file_name}__compo5_no_evaluation_test_set_1.json
    Commit Composition FLAT And Check Response Status To Be 201
    ...     ${opt_file_name}__compo6_no_instruction_test_set_1.json
    Commit Composition FLAT And Check Response Status To Be 201
    ...     ${opt_file_name}__compo8_no_cluster_test_set_1.json

#    ${opt_file_name}    Set Variable    vitagroup-medication-list.v0
#    Upload OPT    query_test_sets/${opt_file_name}.opt
#    Commit Composition FLAT And Check Response Status To Be 201
#    ...     ${opt_file_name}__composition_with_medication_item.json


Change EHR ID In Expected JSON File
    [Arguments]     ${testDataFilePath}
    ${initalJson}           Load Json From File     ${EXPECTED JSON TO RECEIVE PAYLOAD}/${testSet}/${testDataFilePath}
    ${returnedJsonFileLocation}     Change EHR ID and Save Back To Result File
    ...     ${initalJson}   ${ehr_id}      ${testDataFilePath}

Change Query Select In Request JSON File
    [Arguments]     ${testDataFilePath}
    ${initalJson}           Load Json From File     ${ACTUAL JSON TO SEND PAYLOAD}/${testSet}/${testDataFilePath}
    ${returnedJsonFileLocation}     Change EHR ID and Save Back To Request File
    ...     ${initalJson}   ${queryToSendAndExpected}      ${testDataFilePath}

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

Change EHR ID and Save Back To Result File
    [Documentation]     Updates EHR ID value
    ...     in Query result json, using arguments values.
    ...     Takes 3 arguments:
    ...     1 - jsonContent = Loaded Json content
    ...     2 - value to be replaced with New EHR ID
    ...     3 - testDataFilePath - File to be changed
    [Arguments]     ${jsonContent}      ${newEhrIdValue}    ${testDataFilePath}
    ${length}         Get length          ${jsonContent['rows']}
    Log     ${length}
    ${json_object}      Update Value To Json    json_object=${jsonContent}
    ...             json_path=q     new_value=${queryToSendAndExpected}
    # below for is used in case rows contains multiple array results inside rows array
    FOR     ${i}  IN RANGE  ${length}
        ${json_object}          Update Value To Json	json_object=${jsonContent}
        ...             json_path=rows[${i}].[0]
        ...             new_value=${newEhrIdValue}
    END
    ${json_str}     Convert JSON To String    ${json_object}
    Create File     ${EXPECTED JSON TO RECEIVE PAYLOAD}/${testSet}/${testDataFilePath}    ${json_str}
    [return]    ${EXPECTED JSON TO RECEIVE PAYLOAD}/${testSet}/${testDataFilePath}