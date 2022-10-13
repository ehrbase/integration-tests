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
Documentation   QUERY Tests from Tests Set 2
...             \nFirst test Setup is creating OPT, EHR and compositions for Tests Set 2
...             \n*POSTCONDITION* Delete all rows from composition, ehr, status, status_history, template_store

Resource        ../_resources/keywords/composition_keywords.robot
Resource        ../_resources/keywords/admin_keywords.robot
Resource        ../_resources/suite_settings.robot
Resource        ../_resources/keywords/aql_query_keywords.robot

Suite Setup         Clean DB
Suite Teardown      Clean DB


*** Variables ***
${optFile}      ehrbase.testcase0005.v1.opt
${testSet}      test_set_2


*** Test Cases ***
Query For Composition > Observation
    [Tags]      not-ready   bug
    [Setup]     Prepare Test Set 2 From Query Execution
    Execute Query And Compare Actual Result With Expected
    ...     q_composition_observation.json
    ...     q_composition_observation.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-556

Query For Composition[x] > Observation
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_composition_x_observation.json
    ...     q_composition_x_observation.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-556

Query For Composition[x] > Observation[x]
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_composition_x_observation_x.json
    ...     q_composition_x_observation_x.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-556

Query For Composition > Action
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_composition_action.json
    ...     q_composition_action.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-556

Query For Composition[x] > Action
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_composition_x_action.json
    ...     q_composition_x_action.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-556

Query For Composition[x] > Action[x]
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_composition_x_action_x.json
    ...     q_composition_x_action_x.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-556

Query For Composition > Evaluation
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_composition_evaluation.json
    ...     q_composition_evaluation.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-556

Query For Composition[x] > Evaluation
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_composition_x_evaluation.json
    ...     q_composition_x_evaluation.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-556

Query For Composition[x] > Evaluation[x]
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_composition_x_evaluation_x.json
    ...     q_composition_x_evaluation_x.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-556

Query For Composition > Instruction
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_composition_instruction.json
    ...     q_composition_instruction.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-556

Query For Composition[x] > Instruction
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_composition_x_instruction.json
    ...     q_composition_x_instruction.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-556

Query For Composition[x] > Instruction [x]
    Execute Query And Compare Actual Result With Expected
    ...     q_composition_x_instruction_x.json
    ...     q_composition_x_instruction_x.json
    ...     test_set=${testSet}


*** Keywords ***
Prepare Test Set 2 From Query Execution
    ${opt_file_name}    Set Variable    ehrbase.testcase0005.v1
    Upload OPT    query_test_sets/${optFile}
    prepare new request session    JSON    Prefer=return=representation
    create new EHR with subject_id and default subject id value (JSON)
    check content of created EHR (JSON)
    Commit Composition FLAT And Check Response Status To Be 201
    ...     ${opt_file_name}__compo1_test_set_2.json
    Commit Composition FLAT And Check Response Status To Be 201
    ...     ${opt_file_name}__compo2_test_set_2.json
    Commit Composition FLAT And Check Response Status To Be 201
    ...     ${opt_file_name}__compo3_test_set_2.json
    Commit Composition FLAT And Check Response Status To Be 201
    ...     ${opt_file_name}__compo4_no_bp_obs_test_set_2.json
    Commit Composition FLAT And Check Response Status To Be 201
    ...     ${opt_file_name}__compo5_no_action_test_set_2.json
    Commit Composition FLAT And Check Response Status To Be 201
    ...     ${opt_file_name}__compo6_no_evaluation_test_set_2.json
    Commit Composition FLAT And Check Response Status To Be 201
    ...     ${opt_file_name}__compo7_no_instruction_test_set_2.json
    Commit Composition FLAT And Check Response Status To Be 201
    ...     ${opt_file_name}__compo8_no_admin_test_set_2.json