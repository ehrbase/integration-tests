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
Documentation   QUERY Tests from Tests Set 5
...             \nFirst test Setup is creating OPT, EHR and compositions for Tests Set 5
...             \n*POSTCONDITION* Delete all rows from composition, ehr, status, status_history, template_store

Resource        ../_resources/keywords/composition_keywords.robot
Resource        ../_resources/keywords/admin_keywords.robot
Resource        ../_resources/suite_settings.robot
Resource        ../_resources/keywords/aql_query_keywords.robot

Suite Setup         Clean DB
Suite Teardown      Clean DB


*** Variables ***
${optFile}      ehrbase.testcase09.v0.opt
${testSet}      test_set_5


*** Test Cases ***
Query for SECTION
    [Tags]      not-ready   bug
    [Setup]     Prepare Test Set 5 From Query Execution
    Execute Query And Compare Actual Result With Expected
    ...     q_for_section.json
    ...     q_for_section.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-556

Query for SECTION > CLUSTER
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_section_cluster.json
    ...     q_for_section_cluster.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-556

Query for SECTION > ACTION
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_section_action.json
    ...     q_for_section_action.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-556

Query for SECTION > INSTRUCTION
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_section_instruction.json
    ...     q_for_section_instruction.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-556

Query for SECTION [x] > CLUSTER [x]
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_section_x_cluster_x.json
    ...     q_for_section_x_cluster_x.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-556

Query for SECTION > OBSERVATION
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_section_observation.json
    ...     q_for_section_observation.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-556

Query for COMPOSITION > SECTION [x]
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_composition_section_x.json
    ...     q_for_composition_section_x.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-556

Query for COMPOSITION > SECTION > SECTION > OBSERVATION
    [Tags]      not-ready   bug
    Execute Query And Compare Actual Result With Expected
    ...     q_for_composition_section_section_observation.json
    ...     q_for_composition_section_section_observation.json
    ...     test_set=${testSet}
    [Teardown]      TRACE JIRA ISSUE    CDR-556


*** Keywords ***
Prepare Test Set 5 From Query Execution
    ${opt_file_name}    Set Variable    ehrbase.testcase09.v0
    Upload OPT    query_test_sets/${optFile}
    prepare new request session    JSON    Prefer=return=representation
    create new EHR with subject_id and default subject id value (JSON)
    check content of created EHR (JSON)
    Commit Composition FLAT And Check Response Status To Be 201
    ...     ${opt_file_name}__compo1_test_set_5.json
    Commit Composition FLAT And Check Response Status To Be 201
    ...     ${opt_file_name}__compo2_test_set_5.json
    Commit Composition FLAT And Check Response Status To Be 201
    ...     ${opt_file_name}__compo3_test_set_5.json
    Commit Composition FLAT And Check Response Status To Be 201
    ...     ${opt_file_name}__compo4_test_set_5.json
    Commit Composition FLAT And Check Response Status To Be 201
    ...     ${opt_file_name}__compo5_test_set_5.json
    Commit Composition FLAT And Check Response Status To Be 201
    ...     ${opt_file_name}__compo6_test_set_5.json
    Commit Composition FLAT And Check Response Status To Be 201
    ...     ${opt_file_name}__compo7_test_set_5.json