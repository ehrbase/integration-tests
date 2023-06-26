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
...             https://github.com/ehrbase/ehrbase/blob/develop/doc/conformance_testing/COMPOSITION_VALIDATION_DATATYPES.md#321-test-case-dv_ordinal-open-constraint
...             ${\n}*3.2.1. Test case DV_ORDINAL open constraint*
Metadata        TOP_TEST_SUITE    COMPOSITION

Resource        ../../_resources/keywords/composition_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot
Resource        ../../_resources/suite_settings.robot


*** Test Cases ***
Composition With DV_ORDINAL Symbol And Value NULL Open Constraint
    [Tags]      Negative
    [Documentation]     *Test case DV_ORDINAL Symbol And Value NULL Open Constraint:*
    ...     - load json file from CANONICAL_JSON folder
    ...     - update DV_ORDINAL Symbol And Value using:
    ...     - ${symbolValue}, ${dvOrdinalValue} arguments value NULL
    ...     - commit composition
    ...     - check status code of the commited composition.
    ...     - Expected status code on commit composition = 422.
    Set Suite Variable      ${composition_file}    Test_dv_ordinal_open_constraint.v0__.json
    Set Suite Variable      ${optFile}             all_types/Test_dv_ordinal_open_constraint.v0.opt
    Precondition
    ${expectedStatusCode}   Set Variable    422
    ${statusCodeBoolean}    Commit Composition With Modified DV_ORDINAL Symbol And Value
    ...     ${NULL}     ${NULL}     ${expectedStatusCode}
    IF      ${statusCodeBoolean} == ${FALSE}
        Fail    Commit composition expected status code ${expectedStatusCode} is different.
    END
    [Teardown]  Delete Composition Using API

Composition With DV_ORDINAL Symbol NULL And Value 1 Open Constraint
    [Tags]      Negative
    [Documentation]     *Test case DV_ORDINAL Symbol NULL And Value 1 Open Constraint:*
    ...     - load json file from CANONICAL_JSON folder
    ...     - update DV_ORDINAL Symbol And Value using:
    ...     - ${symbolValue}, ${dvOrdinalValue} arguments values are NULL, 1
    ...     - commit composition
    ...     - check status code of the commited composition.
    ...     - Expected status code on commit composition = 422.
    ${expectedStatusCode}   Set Variable    422
    ${statusCodeBoolean}    Commit Composition With Modified DV_ORDINAL Symbol And Value
    ...     ${NULL}     1     ${expectedStatusCode}
    IF      ${statusCodeBoolean} == ${FALSE}
        Fail    Commit composition expected status code ${expectedStatusCode} is different.
    END
    [Teardown]  Delete Composition Using API

Composition With DV_ORDINAL Symbol local::at0005 And Value NULL Open Constraint
    [Tags]      Negative
    [Documentation]     *Test case DV_ORDINAL Symbol local::at0005 And Value NULL Open Constraint:*
    ...     - load json file from CANONICAL_JSON folder
    ...     - update DV_ORDINAL Symbol And Value using:
    ...     - ${symbolValue}, ${dvOrdinalValue} arguments values are local::at0005, NULL
    ...     - commit composition
    ...     - check status code of the commited composition.
    ...     - Expected status code on commit composition = 422.
    ${expectedStatusCode}   Set Variable    422
    ${newDict}  Prepare Dictionary To Be Added In DV_ORDINAL Symbol
    ${statusCodeBoolean}    Commit Composition With Modified DV_ORDINAL Symbol And Value
    ...     ${newDict}     ${NULL}     ${expectedStatusCode}
    IF      ${statusCodeBoolean} == ${FALSE}
        Fail    Commit composition expected status code ${expectedStatusCode} is different.
    END
    [Teardown]  Delete Composition Using API

Composition With DV_ORDINAL Symbol local::at0005 And Value 1 Open Constraint
    [Tags]      Positive
    [Documentation]     *Test case DV_ORDINAL Symbol local::at0005 And Value 1 Open Constraint:*
    ...     - load json file from CANONICAL_JSON folder
    ...     - update DV_ORDINAL Symbol And Value using:
    ...     - ${symbolValue}, ${dvOrdinalValue} arguments values are local::at0005, 1
    ...     - commit composition
    ...     - check status code of the commited composition.
    ...     - Expected status code on commit composition = 201.
    ${expectedStatusCode}   Set Variable    201
    ${newDict}  Prepare Dictionary To Be Added In DV_ORDINAL Symbol
    ${statusCodeBoolean}    Commit Composition With Modified DV_ORDINAL Symbol And Value
    ...     ${newDict}     1     ${expectedStatusCode}
    IF      ${statusCodeBoolean} == ${FALSE}
        Fail    Commit composition expected status code ${expectedStatusCode} is different.
    END
    [Teardown]  Run Keywords    Delete Composition Using API    AND     Delete Template Using API


*** Keywords ***
Precondition
    Upload OPT    ${optFile}
    create EHR

Commit Composition With Modified DV_ORDINAL Symbol And Value
    [Arguments]     ${symbolValue}=local::at0005
    ...             ${dvOrdinalValue}=123
    ...             ${expectedCode}=201
    Load Json File With Composition
    ${initalJson}           Load Json From File     ${compositionFilePath}
    ${returnedJsonFile}     Change Json KeyValue and Save Back To File
    ...     ${initalJson}   ${symbolValue}      ${dvOrdinalValue}
    commit composition      format=CANONICAL_JSON
    ...                     composition=${composition_file}
    ${isStatusCodeEqual}    Run Keyword And Return Status
    ...     Should Be Equal As Strings      ${response.status_code}     ${expectedCode}
    ${isUidPresent}     Run Keyword And Return Status
    ...     Set Test Variable   ${version_uid}    ${response.json()['uid']['value']}
    IF      ${isUidPresent} == ${TRUE}
        ${short_uid}        Remove String       ${version_uid}    ::${CREATING_SYSTEM_ID}::1
                            Set Suite Variable   ${versioned_object_uid}    ${short_uid}
    ELSE
        Set Suite Variable   ${versioned_object_uid}    ${None}
    END
    [Return]    ${isStatusCodeEqual}

Change Json KeyValue and Save Back To File
    [Documentation]     Updates DV_ORDINAL Symbol And Value
    ...     in Composition json, using arguments values.
    ...     Takes 3 arguments:
    ...     1 - jsonContent = Loaded Json content
    ...     2 - value to be on dv_ordinal.symbol
    ...     3 - value to be on dv_ordinal.value
    [Arguments]     ${jsonContent}      ${symbolValueToUpdate}      ${dvOrdinalValueToUpdate}
    ${symbolValueJsonPath1}     Set Variable
    ...     content[0].data.events[0].data.items[0].value.symbol
    ${symbolValueJsonPath2}     Set Variable
    ...     content[0].data.events[1].data.items[0].value.symbol
    ${symbolValueJsonPath3}     Set Variable
    ...     content[0].data.events[2].data.items[0].value.symbol
    ${dvOrdinalValueJsonPath1}     Set Variable
    ...     content[0].data.events[0].data.items[0].value.value
    ${dvOrdinalValueJsonPath2}     Set Variable
    ...     content[0].data.events[1].data.items[0].value.value
    ${dvOrdinalValueJsonPath3}     Set Variable
    ...     content[0].data.events[2].data.items[0].value.value
    ${json_object}          Update Value To Json	json_object=${jsonContent}
    ...             json_path=${symbolValueJsonPath1}
    ...             new_value=${symbolValueToUpdate}
    ${json_object}          Update Value To Json	json_object=${jsonContent}
    ...             json_path=${symbolValueJsonPath2}
    ...             new_value=${symbolValueToUpdate}
    ${json_object}          Update Value To Json	json_object=${jsonContent}
    ...             json_path=${symbolValueJsonPath3}
    ...             new_value=${symbolValueToUpdate}
    ${json_object}          Update Value To Json	json_object=${jsonContent}
    ...             json_path=${dvOrdinalValueJsonPath1}
    ...             new_value=${dvOrdinalValueToUpdate}
    ${json_object}          Update Value To Json	json_object=${jsonContent}
    ...             json_path=${dvOrdinalValueJsonPath2}
    ...             new_value=${dvOrdinalValueToUpdate}
    ${json_object}          Update Value To Json	json_object=${jsonContent}
    ...             json_path=${dvOrdinalValueJsonPath3}
    ...             new_value=${dvOrdinalValueToUpdate}
    ${changedSymbolValue1}   Get Value From Json     ${jsonContent}      ${symbolValueJsonPath1}
    ${changedSymbolValue2}   Get Value From Json     ${jsonContent}      ${symbolValueJsonPath2}
    ${changedSymbolValue3}   Get Value From Json     ${jsonContent}      ${symbolValueJsonPath3}
    ${changedDvOrdinalValue1}   Get Value From Json     ${jsonContent}      ${dvOrdinalValueJsonPath1}
    ${changedDvOrdinalValue2}   Get Value From Json     ${jsonContent}      ${dvOrdinalValueJsonPath2}
    ${changedDvOrdinalValue3}   Get Value From Json     ${jsonContent}      ${dvOrdinalValueJsonPath3}
    ${json_str}     Convert JSON To String    ${json_object}
    Create File     ${compositionFilePath}    ${json_str}
    [return]    ${compositionFilePath}

Prepare Dictionary To Be Added In DV_ORDINAL Symbol
    &{terminologyIdContent}		Create Dictionary	_type=TERMINOLOGY_ID	value=external
    &{definingCodeContent}		Create Dictionary	_type=CODE_PHRASE	terminology_id=${terminologyIdContent}		code_string=kg
    &{mainDict}     Create Dictionary   type=DV_CODED_TEXT      value=local::at0005		defining_code=${definingCodeContent}
    [Return]        ${mainDict}