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
Documentation   Composition Integration Tests
...             ${\n}Based on:
...             https://github.com/ehrbase/ehrbase/blob/develop/doc/conformance_testing/COMPOSITION_VALIDATION_DATATYPES.md#451-test-case-dv_date_time-open-constraint
...             ${\n}*4.5.1. Test case DV_DATE_TIME open constraint*
Metadata        TOP_TEST_SUITE    COMPOSITION

Resource        ../../_resources/keywords/composition_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot
Resource        ../../_resources/suite_settings.robot

Suite Setup       Precondition


*** Variables ***
${composition_file}      Test_all_types_v2__.json
${composition_file_tmp}      Test_all_types_v2.tmp__.json


*** Test Cases ***
Create Composition With DV_DATE_TIME Combinations - Positive
    [Documentation]     *Operations done here (Positive flows):*
    ...     - load json file from CANONICAL_JSON folder
    ...     - update DV_DATE_TIME using ${dvDateTimeValue} argument value
    ...     - commit composition
    ...     - check status code of the commited composition to be 201.
    ...     *Postcondition:* Add DV_DATE_TIME value 2021-10-24T10, to ${composition_file}.
    [Template]      PositiveCompositionTemplate
    #2021T00:00:00
    #2021-10T00:00:00
    2021-10-24T00:00:00
    2021-10-24T10
    2021-10-24T10:30
    2021-10-24T10:30:47
    2021-10-24T10:30:47.5
    2021-10-24T10:30:47.333
    2021-10-24T10:30:47.333333
    2021-10-24T10:30:47Z
    2021-10-24T10:30:47.5Z
    2021-10-24T10:30:47.333Z
    2021-10-24T10:30:47.333333Z
    2021-10-24T10:30:47-03:00
    2021-10-24T10:30:47.5-03:00
    2021-10-24T10:30:47.333-03:00
    2021-10-24T10:30:47.333333-03:00
    [Teardown]      PositiveCompositionTemplate     2021-10-24T10

Create Composition With DV_DATE_TIME Combinations - Negative
    [Documentation]     *Operations done here (Negative flows):*
    ...     - load json file from CANONICAL_JSON folder
    ...     - update DV_DATE_TIME using ${dvDateTimeValue} argument value
    ...     - commit composition
    ...     - check status code of the commited composition to be 400.
    ...     *Postcondition:* Add DV_DATE_TIME value 2021-10-24T10, to ${composition_file}.
    [Template]      NegativeCompositionTemplate
    NULL
    ${EMPTY}
    2021-00
    2021-13
    2021-10-00
    2021-10-32
    2021-10-24T48
    2021-10-24T10:95
    2021-10-24T10:30:78
    2021-10-24T10:30:78Z
    2021-10-24T10:30:78-03:00
    [Teardown]      Run Keywords    PositiveCompositionTemplate     2021-10-24T10   AND
                    ...     (admin) delete ehr      AND     (admin) delete all OPTs


*** Keywords ***
Precondition
    Set Library Search Order For Tests
    Upload OPT    all_types/Test_all_types_v2.opt
    create EHR

PositiveCompositionTemplate
    [Arguments]     ${dvDateTimeValue}=2021-10-24
    Load Json File With Composition
    ${initalJson}           Load Json From File     ${compositionFilePath}
    ${returnedJsonFile}     Change Json KeyValue and Save Back To File
    ...     ${initalJson}   ${dvDateTimeValue}
    commit composition      format=CANONICAL_JSON
    ...                     composition=${composition_file_tmp}
    Should Be Equal As Strings      ${response.status_code}     201
    [Teardown]      Remove File     ${returnedJsonFile}

NegativeCompositionTemplate
    [Arguments]     ${dvDateTimeValue}=2021-13
    Load Json File With Composition
    ${initalJson}           Load Json From File     ${compositionFilePath}
    ${returnedJsonFile}     Change Json KeyValue and Save Back To File
    ...     ${initalJson}   ${dvDateTimeValue}
    commit composition      format=CANONICAL_JSON
    ...                     composition=${composition_file_tmp}
    Should Be Equal As Strings      ${response.status_code}     400
    [Teardown]      Remove File     ${returnedJsonFile}

Change Json KeyValue and Save Back To File
    [Documentation]     Updates $..data.events..items.[7].value.value to
    ...     value provided as argument.
    ...     Takes 2 arguments:
    ...     1 - jsonContent = Loaded Json content
    ...     2 - value to be on $..data.events..items.[7].value.value key
    [Arguments]     ${jsonContent}      ${valueToUpdate}
    #${objPath}      Set Variable        $..data.events..items.[?(@._type=='DV_TIME')].value
    ${objPath}      Set Variable        $..data.events..items.[7].value.value
    ${json_object}  Update Value To Json	json_object=${jsonContent}
    ...             json_path=${objPath}    new_value=${valueToUpdate}
    ${changedDvDateTimeValue}   Get Value From Json     ${json_object}      ${objPath}
    Should Be Equal     ${changedDvDateTimeValue[0]}   ${valueToUpdate}
    ${json_str}     Convert JSON To String    ${json_object}
    Create File     ${COMPO DATA SETS}/CANONICAL_JSON/${composition_file_tmp}    ${json_str}
    RETURN    ${COMPO DATA SETS}/CANONICAL_JSON/${composition_file_tmp}