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
...             \nBased on:
...             - https://github.com/ehrbase/ehrbase/blob/develop/doc/conformance_testing/COMPOSITION_VALIDATION_DATATYPES.md#371-test-case-dv_intervaldv_count-open-constraint
...             - https://github.com/ehrbase/ehrbase/blob/develop/doc/conformance_testing/COMPOSITION_VALIDATION_DATATYPES.md#372-test-case-dv_intervaldv_count-lower-and-upper-range-constraint
...             \n*3.7.1. Test case DV_INTERVAL<DV_COUNT> open constraint*
...             \n*3.7.2. Test case DV_INTERVAL<DV_COUNT> lower and upper range constraint*
...             \nIn tests name (applicable for lower_unb, upper_unb, lower_incl, upper_incl):
...             - 1 is True
...             - 0 is False
Metadata        TOP_TEST_SUITE    COMPOSITION

Resource        ../../_resources/keywords/composition_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot
Resource        ../../_resources/suite_settings.robot
Suite Setup     Set Library Search Order For Tests


*** Test Cases ***
3.7.1. Test DV_INTERVAL<DV_COUNT> Lower -20 - Upper -5 - Lower Unb 0 - Upper Unb 0 - Lower Incl 0 - Upper Incl 0
    [Tags]      Positive
    [Documentation]     Positive case for DV_INTERVAL<DV_COUNT>
    ...     Lower -20, Upper -5, Lower Unb 0, Upper Unb 0, Lower Incl 0, Upper Incl 0
    ...     *See suite documentation to understand what are 1 and 0 values!*
    ...     - load json file from CANONICAL_JSON folder
    ...     - set ${dvLower}, ${dvUpper}, ${dvLowerUnb}, ${dvUpperUnb}, ${dvLowerIncl}, ${dvUpperIncl}
    ...     - commit composition\n- check status code of the commited composition.
    ...     - Expected status code on commit composition = 201.
    Set Suite Variable      ${composition_file}    Test_dv_interval_dv_count_open_constraint.v0__.json
    Set Suite Variable      ${optFile}             all_types/Test_dv_interval_dv_count_open_constraint.v0.opt
    Precondition
    ${expectedStatusCode}   Set Variable    201
    ${statusCodeBoolean}    Commit Composition With Modified DV_INTERVAL<DV_COUNT> Values
    ...     ${-20}       ${-5}
    ...     ${FALSE}     ${FALSE}     ${FALSE}    ${FALSE}
    ...     ${expectedStatusCode}
    IF      ${statusCodeBoolean} == ${FALSE}
        Fail    Commit composition expected status code ${expectedStatusCode} is different.
    END
    [Teardown]     Delete Composition Using API

Test DV_INTERVAL<DV_COUNT> Lower 0 - Upper 100 - Lower Unb 0 - Upper Unb 0 - Lower Incl 1 - Upper Incl 1
    [Tags]      Positive
    [Documentation]     Positive case for DV_INTERVAL<DV_COUNT>
    ...     Lower 0, Upper 100, Lower Unb 0, Upper Unb 0, Lower Incl 1, Upper Incl 1
    ...     *See suite documentation to understand what are 1 and 0 values!*
    ...     - load json file from CANONICAL_JSON folder
    ...     - set ${dvLower}, ${dvUpper}, ${dvLowerUnb}, ${dvUpperUnb}, ${dvLowerIncl}, ${dvUpperIncl}
    ...     - commit composition\n- check status code of the commited composition.
    ...     - Expected status code on commit composition = 201.
    ${expectedStatusCode}   Set Variable    201
    ${statusCodeBoolean}    Commit Composition With Modified DV_INTERVAL<DV_COUNT> Values
    ...     ${0}       ${100}
    ...     ${FALSE}     ${FALSE}     ${TRUE}    ${TRUE}
    ...     ${expectedStatusCode}
    IF      ${statusCodeBoolean} == ${FALSE}
        Fail    Commit composition expected status code ${expectedStatusCode} is different.
    END
    [Teardown]     Delete Composition Using API

Test DV_INTERVAL<DV_COUNT> Lower 10 - Upper 100 - Lower Unb 0 - Upper Unb 0 - Lower Incl 1 - Upper Incl 1
    [Tags]      Positive
    [Documentation]     Positive case for DV_INTERVAL<DV_COUNT>
    ...     Lower 10, Upper 100, Lower Unb 0, Upper Unb 0, Lower Incl 1, Upper Incl 1
    ...     *See suite documentation to understand what are 1 and 0 values!*
    ...     - load json file from CANONICAL_JSON folder
    ...     - set ${dvLower}, ${dvUpper}, ${dvLowerUnb}, ${dvUpperUnb}, ${dvLowerIncl}, ${dvUpperIncl}
    ...     - commit composition\n- check status code of the commited composition.
    ...     - Expected status code on commit composition = 201.
    ${expectedStatusCode}   Set Variable    201
    ${statusCodeBoolean}    Commit Composition With Modified DV_INTERVAL<DV_COUNT> Values
    ...     ${10}       ${100}
    ...     ${FALSE}     ${FALSE}     ${TRUE}    ${TRUE}
    ...     ${expectedStatusCode}
    IF      ${statusCodeBoolean} == ${FALSE}
        Fail    Commit composition expected status code ${expectedStatusCode} is different.
    END
    [Teardown]     Delete Composition Using API

Test DV_INTERVAL<DV_COUNT> Lower -50 - Upper 50 - Lower Unb 0 - Upper Unb 0 - Lower Incl 1 - Upper Incl 1
    [Tags]      Positive
    [Documentation]     Positive case for DV_INTERVAL<DV_COUNT>
    ...     Lower -50, Upper 50, Lower Unb 0, Upper Unb 0, Lower Incl 1, Upper Incl 1
    ...     *See suite documentation to understand what are 1 and 0 values!*
    ...     - load json file from CANONICAL_JSON folder
    ...     - set ${dvLower}, ${dvUpper}, ${dvLowerUnb}, ${dvUpperUnb}, ${dvLowerIncl}, ${dvUpperIncl}
    ...     - commit composition\n- check status code of the commited composition.
    ...     - Expected status code on commit composition = 201.
    ${expectedStatusCode}   Set Variable    201
    ${statusCodeBoolean}    Commit Composition With Modified DV_INTERVAL<DV_COUNT> Values
    ...     ${-50}       ${50}
    ...     ${FALSE}     ${FALSE}     ${TRUE}    ${TRUE}
    ...     ${expectedStatusCode}
    IF      ${statusCodeBoolean} == ${FALSE}
        Fail    Commit composition expected status code ${expectedStatusCode} is different.
    END
    [Teardown]     Delete Composition Using API

Test DV_INTERVAL<DV_COUNT> Lower Null - Upper Null - Lower Unb 1 - Upper Unb 1 - Lower Incl 1 - Upper Incl 0
    [Tags]      Negative
    [Documentation]     Positive case for DV_INTERVAL<DV_COUNT>
    ...     Lower Null, Upper Null, Lower Unb 1, Upper Unb 1, Lower Incl 1, Upper Incl 0
    ...     *See suite documentation to understand what are 1 and 0 values!*
    ...     - load json file from CANONICAL_JSON folder
    ...     - set ${dvLower}, ${dvUpper}, ${dvLowerUnb}, ${dvUpperUnb}, ${dvLowerIncl}, ${dvUpperIncl}
    ...     - commit composition\n- check status code of the commited composition.
    ...     - Expected status code on commit composition = 422.
    ...     - Expect error message: Invariant Lower_included_valid failed on type INTERVAL
    ${expectedStatusCode}   Set Variable    422
    ${statusCodeBoolean}    Commit Composition With Modified DV_INTERVAL<DV_COUNT> Values
    ...     ${NULL}     ${NULL}
    ...     ${TRUE}     ${TRUE}     ${TRUE}    ${FALSE}
    ...     ${expectedStatusCode}
    Should Contain      ${response.json()["message"]}      Invariant Lower_included_valid failed on type INTERVAL
    IF      ${statusCodeBoolean} == ${FALSE}
        Fail    Commit composition expected status code ${expectedStatusCode} is different.
    END
    [Teardown]     Delete Composition Using API

Test DV_INTERVAL<DV_COUNT> Lower 0 - Upper Null - Lower Unb 0 - Upper Unb 1 - Lower Incl 0 - Upper Incl 1
    [Tags]      Negative
    [Documentation]     Positive case for DV_INTERVAL<DV_COUNT>
    ...     Lower 0, Upper Null, Lower Unb 0, Upper Unb 1, Lower Incl 0, Upper Incl 1
    ...     *See suite documentation to understand what are 1 and 0 values!*
    ...     - load json file from CANONICAL_JSON folder
    ...     - set ${dvLower}, ${dvUpper}, ${dvLowerUnb}, ${dvUpperUnb}, ${dvLowerIncl}, ${dvUpperIncl}
    ...     - commit composition\n- check status code of the commited composition.
    ...     - Expected status code on commit composition = 422.
    ...     - Expect error message: Invariant Upper_included_valid failed on type INTERVAL
    ${expectedStatusCode}   Set Variable    422
    ${statusCodeBoolean}    Commit Composition With Modified DV_INTERVAL<DV_COUNT> Values
    ...     ${0}     ${NULL}
    ...     ${FALSE}     ${TRUE}     ${FALSE}    ${TRUE}
    ...     ${expectedStatusCode}
    Should Contain      ${response.json()["message"]}      Invariant Upper_included_valid failed on type INTERVAL
    IF      ${statusCodeBoolean} == ${FALSE}
        Fail    Commit composition expected status code ${expectedStatusCode} is different.
    END
    [Teardown]     Delete Composition Using API

Test DV_INTERVAL<DV_COUNT> Lower 200 - Upper 100 - Lower Unb 0 - Upper Unb 0 - Lower Incl 1 - Upper Incl 1
    [Tags]      Negative
    [Documentation]     Positive case for DV_INTERVAL<DV_COUNT>
    ...     Lower 200, Upper 100, Lower Unb 0, Upper Unb 0, Lower Incl 1, Upper Incl 1
    ...     *See suite documentation to understand what are 1 and 0 values!*
    ...     - load json file from CANONICAL_JSON folder
    ...     - set ${dvLower}, ${dvUpper}, ${dvLowerUnb}, ${dvUpperUnb}, ${dvLowerIncl}, ${dvUpperIncl}
    ...     - commit composition\n- check status code of the commited composition.
    ...     - Expected status code on commit composition = 422.
    ...     - Expect error message: Invariant Limits_consistent failed on type INTERVAL
    ${expectedStatusCode}   Set Variable    422
    ${statusCodeBoolean}    Commit Composition With Modified DV_INTERVAL<DV_COUNT> Values
    ...     ${200}     ${100}
    ...     ${FALSE}     ${FALSE}     ${TRUE}    ${TRUE}
    ...     ${expectedStatusCode}
    Log     ${response.json()["message"]}
    Should Contain      ${response.json()["message"]}      Invariant Limits_consistent failed on type INTERVAL
    IF      ${statusCodeBoolean} == ${FALSE}
        Fail    Commit composition expected status code ${expectedStatusCode} is different.
    END
    [Teardown]      Run Keywords    Delete Composition Using API    AND     Delete Template Using API   AND
                    ...     (admin) delete ehr      AND     (admin) delete all OPTs

3.7.2. Test DV_INTERVAL<DV_COUNT> Lower 0 - Upper 100 - Lower Unb 0 - Upper Unb 0 - Lower Incl 1 - Upper Incl 1 With Lower Upper Constraint
    [Tags]      Positive
    [Documentation]     Positive case for DV_INTERVAL<DV_COUNT>
    ...     Lower 0, Upper 100, Lower Unb 0, Upper Unb 0, Lower Incl 1, Upper Incl 1 With Lower Upper Constraint
    ...     *See suite documentation to understand what are 1 and 0 values!*
    ...     - load json file from CANONICAL_JSON folder
    ...     - set ${dvLower}, ${dvUpper}, ${dvLowerUnb}, ${dvUpperUnb}, ${dvLowerIncl}, ${dvUpperIncl}
    ...     - commit composition\n- check status code of the commited composition.
    ...     - Expected status code on commit composition = 201.
    Set Suite Variable      ${composition_file}    Test_dv_interval_dv_count_lower_upper_constraint.v0__.json
    Set Suite Variable      ${optFile}             all_types/Test_dv_interval_dv_count_lower_upper_constraint.v0.opt
    Precondition
    ${expectedStatusCode}   Set Variable    201
    ${statusCodeBoolean}    Commit Composition With Modified DV_INTERVAL<DV_COUNT> Values
    ...     ${0}     ${100}
    ...     ${FALSE}     ${FALSE}     ${TRUE}    ${TRUE}
    ...     ${expectedStatusCode}
    IF      ${statusCodeBoolean} == ${FALSE}
        Fail    Commit composition expected status code ${expectedStatusCode} is different.
    END
    [Teardown]     Delete Composition Using API

Test DV_INTERVAL<DV_COUNT> Lower -10 - Upper 100 - Lower Unb 0 - Upper Unb 0 - Lower Incl 1 - Upper Incl 1 With Lower Upper Constraint
    [Tags]      Negative
    [Documentation]     Negative case for DV_INTERVAL<DV_COUNT>
    ...     Lower -10, Upper 100, Lower Unb 0, Upper Unb 0, Lower Incl 1, Upper Incl 1 With Lower Upper Constraint
    ...     *See suite documentation to understand what are 1 and 0 values!*
    ...     - load json file from CANONICAL_JSON folder
    ...     - set ${dvLower}, ${dvUpper}, ${dvLowerUnb}, ${dvUpperUnb}, ${dvLowerIncl}, ${dvUpperIncl}
    ...     - commit composition\n- check status code of the commited composition.
    ...     - Expected status code on commit composition = 422.
    ${expectedStatusCode}   Set Variable    422
    ${statusCodeBoolean}    Commit Composition With Modified DV_INTERVAL<DV_COUNT> Values
    ...     ${-10}     ${100}
    ...     ${FALSE}     ${FALSE}     ${TRUE}    ${TRUE}
    ...     ${expectedStatusCode}
    Should Contain      ${response.json()["message"]}   The value -10 must be at least 0 and at most 100
    IF      ${statusCodeBoolean} == ${FALSE}
        Fail    Commit composition expected status code ${expectedStatusCode} is different.
    END
    [Teardown]     Delete Composition Using API

Test DV_INTERVAL<DV_COUNT> Lower 0 - Upper 200 - Lower Unb 0 - Upper Unb 0 - Lower Incl 1 - Upper Incl 1 With Lower Upper Constraint
    [Tags]      Negative
    [Documentation]     Negative case for DV_INTERVAL<DV_COUNT>
    ...     Lower 0, Upper 200, Lower Unb 0, Upper Unb 0, Lower Incl 1, Upper Incl 1 With Lower Upper Constraint
    ...     *See suite documentation to understand what are 1 and 0 values!*
    ...     - load json file from CANONICAL_JSON folder
    ...     - set ${dvLower}, ${dvUpper}, ${dvLowerUnb}, ${dvUpperUnb}, ${dvLowerIncl}, ${dvUpperIncl}
    ...     - commit composition\n- check status code of the commited composition.
    ...     - Expected status code on commit composition = 422.
    ${expectedStatusCode}   Set Variable    422
    ${statusCodeBoolean}    Commit Composition With Modified DV_INTERVAL<DV_COUNT> Values
    ...     ${0}     ${200}
    ...     ${FALSE}     ${FALSE}     ${TRUE}    ${TRUE}
    ...     ${expectedStatusCode}
    Should Contain      ${response.json()["message"]}   The value 200 must be at least 0 and at most 100
    IF      ${statusCodeBoolean} == ${FALSE}
        Fail    Commit composition expected status code ${expectedStatusCode} is different.
    END
    [Teardown]     Delete Composition Using API

Test DV_INTERVAL<DV_COUNT> Lower -10 - Upper 200 - Lower Unb 0 - Upper Unb 0 - Lower Incl 1 - Upper Incl 1 With Lower Upper Constraint
    [Tags]      Negative
    [Documentation]     Negative case for DV_INTERVAL<DV_COUNT>
    ...     Lower -10, Upper 200, Lower Unb 0, Upper Unb 0, Lower Incl 1, Upper Incl 1 With Lower Upper Constraint
    ...     *See suite documentation to understand what are 1 and 0 values!*
    ...     - load json file from CANONICAL_JSON folder
    ...     - set ${dvLower}, ${dvUpper}, ${dvLowerUnb}, ${dvUpperUnb}, ${dvLowerIncl}, ${dvUpperIncl}
    ...     - commit composition\n- check status code of the commited composition.
    ...     - Expected status code on commit composition = 422.
    ${expectedStatusCode}   Set Variable    422
    ${statusCodeBoolean}    Commit Composition With Modified DV_INTERVAL<DV_COUNT> Values
    ...     ${-10}     ${200}
    ...     ${FALSE}     ${FALSE}     ${TRUE}    ${TRUE}
    ...     ${expectedStatusCode}
    Should Contain      ${response.json()["message"]}      The value -10 must be at least 0 and at most 100
    Should Contain      ${response.json()["message"]}      The value 200 must be at least 0 and at most 100
    IF      ${statusCodeBoolean} == ${FALSE}
        Fail    Commit composition expected status code ${expectedStatusCode} is different.
    END
    [Teardown]      Run Keywords    Delete Composition Using API    AND     Delete Template Using API   AND
                    ...     (admin) delete ehr      AND     (admin) delete all OPTs

### Below cases are not valid as NULL value is not possible on DV_COUNT.magnitude
#CDR-539 - is not valid bug

#3.7.1. Test DV_INTERVAL<DV_COUNT> Lower Null - Upper Null - Lower Unb 1 - Upper Unb 1 - Lower Incl 0 - Upper Incl 0
#    [Tags]      Positive    bug
#    [Documentation]     Positive case for DV_INTERVAL<DV_COUNT>
#    ...     Lower Null, Upper Null, Lower Unb 1, Upper Unb 1, Lower Incl 0, Upper Incl 0
#    ...     *See suite documentation to understand what are 1 and 0 values!*
#    ...     - load json file from CANONICAL_JSON folder
#    ...     - set ${dvLower}, ${dvUpper}, ${dvLowerUnb}, ${dvUpperUnb}, ${dvLowerIncl}, ${dvUpperIncl}
#    ...     - commit composition\n- check status code of the commited composition.
#    ...     - Expected status code on commit composition = 201.
#    Set Suite Variable      ${composition_file}    Test_dv_interval_dv_count_open_constraint.v0__.json
#    Set Suite Variable      ${optFile}             all_types/Test_dv_interval_dv_count_open_constraint.v0.opt
#    Precondition
#    ${expectedStatusCode}   Set Variable    201
#    ${statusCodeBoolean}    Commit Composition With Modified DV_INTERVAL<DV_COUNT> Values
#    ...     ${NULL}     ${NULL}
#    ...     ${TRUE}     ${TRUE}     ${FALSE}    ${FALSE}
#    ...     ${expectedStatusCode}
#    IF      ${statusCodeBoolean} == ${FALSE}
#        Fail    Commit composition expected status code ${expectedStatusCode} is different.
#    END
#    [Teardown]     Run Keywords     Delete Composition Using API    AND     TRACE JIRA ISSUE    CDR-539
#
#Test DV_INTERVAL<DV_COUNT> Lower Null - Upper 100 - Lower Unb 1 - Upper Unb 0 - Lower Incl 0 - Upper Incl 0
#    [Tags]      Positive    bug
#    [Documentation]     Positive case for DV_INTERVAL<DV_COUNT>
#    ...     Lower Null, Upper 100, Lower Unb 1, Upper Unb 0, Lower Incl 0, Upper Incl 0
#    ...     *See suite documentation to understand what are 1 and 0 values!*
#    ...     - load json file from CANONICAL_JSON folder
#    ...     - set ${dvLower}, ${dvUpper}, ${dvLowerUnb}, ${dvUpperUnb}, ${dvLowerIncl}, ${dvUpperIncl}
#    ...     - commit composition\n- check status code of the commited composition.
#    ...     - Expected status code on commit composition = 201.
#    ${expectedStatusCode}   Set Variable    201
#    ${statusCodeBoolean}    Commit Composition With Modified DV_INTERVAL<DV_COUNT> Values
#    ...     ${NULL}     ${100}
#    ...     ${TRUE}     ${FALSE}     ${FALSE}    ${FALSE}
#    ...     ${expectedStatusCode}
#    IF      ${statusCodeBoolean} == ${FALSE}
#        Fail    Commit composition expected status code ${expectedStatusCode} is different.
#    END
#    [Teardown]     Run Keywords     Delete Composition Using API    AND     TRACE JIRA ISSUE    CDR-539
#
#Test DV_INTERVAL<DV_COUNT> Lower Null - Upper 100 - Lower Unb 1 - Upper Unb 0 - Lower Incl 0 - Upper Incl 1
#    [Tags]      Positive    bug
#    [Documentation]     Positive case for DV_INTERVAL<DV_COUNT>
#    ...     Lower Null, Upper 100, Lower Unb 1, Upper Unb 0, Lower Incl 0, Upper Incl 1
#    ...     *See suite documentation to understand what are 1 and 0 values!*
#    ...     - load json file from CANONICAL_JSON folder
#    ...     - set ${dvLower}, ${dvUpper}, ${dvLowerUnb}, ${dvUpperUnb}, ${dvLowerIncl}, ${dvUpperIncl}
#    ...     - commit composition\n- check status code of the commited composition.
#    ...     - Expected status code on commit composition = 201.
#    ${expectedStatusCode}   Set Variable    201
#    ${statusCodeBoolean}    Commit Composition With Modified DV_INTERVAL<DV_COUNT> Values
#    ...     ${NULL}     ${100}
#    ...     ${TRUE}     ${FALSE}     ${FALSE}    ${TRUE}
#    ...     ${expectedStatusCode}
#    IF      ${statusCodeBoolean} == ${FALSE}
#        Fail    Commit composition expected status code ${expectedStatusCode} is different.
#    END
#    [Teardown]     Run Keywords     Delete Composition Using API    AND     TRACE JIRA ISSUE    CDR-539
#
#Test DV_INTERVAL<DV_COUNT> Lower 0 - Upper Null - Lower Unb 0 - Upper Unb 1 - Lower Incl 0 - Upper Incl 0
#    [Tags]      Positive    bug
#    [Documentation]     Positive case for DV_INTERVAL<DV_COUNT>
#    ...     Lower 0, Upper Null, Lower Unb 0, Upper Unb 1, Lower Incl 0, Upper Incl 0
#    ...     *See suite documentation to understand what are 1 and 0 values!*
#    ...     - load json file from CANONICAL_JSON folder
#    ...     - set ${dvLower}, ${dvUpper}, ${dvLowerUnb}, ${dvUpperUnb}, ${dvLowerIncl}, ${dvUpperIncl}
#    ...     - commit composition\n- check status code of the commited composition.
#    ...     - Expected status code on commit composition = 201.
#    ${expectedStatusCode}   Set Variable    201
#    ${statusCodeBoolean}    Commit Composition With Modified DV_INTERVAL<DV_COUNT> Values
#    ...     ${0}       ${NULL}
#    ...     ${FALSE}     ${TRUE}     ${FALSE}    ${FALSE}
#    ...     ${expectedStatusCode}
#    IF      ${statusCodeBoolean} == ${FALSE}
#        Fail    Commit composition expected status code ${expectedStatusCode} is different.
#    END
#    [Teardown]     Run Keywords     Delete Composition Using API    AND     TRACE JIRA ISSUE    CDR-539
#
#Test DV_INTERVAL<DV_COUNT> Lower 0 - Upper Null - Lower Unb 0 - Upper Unb 1 - Lower Incl 1 - Upper Incl 0
#    [Tags]      Positive    bug
#    [Documentation]     Positive case for DV_INTERVAL<DV_COUNT>
#    ...     Lower 0, Upper Null, Lower Unb 0, Upper Unb 1, Lower Incl 1, Upper Incl 0
#    ...     *See suite documentation to understand what are 1 and 0 values!*
#    ...     - load json file from CANONICAL_JSON folder
#    ...     - set ${dvLower}, ${dvUpper}, ${dvLowerUnb}, ${dvUpperUnb}, ${dvLowerIncl}, ${dvUpperIncl}
#    ...     - commit composition\n- check status code of the commited composition.
#    ...     - Expected status code on commit composition = 201.
#    ${expectedStatusCode}   Set Variable    201
#    ${statusCodeBoolean}    Commit Composition With Modified DV_INTERVAL<DV_COUNT> Values
#    ...     ${0}       ${NULL}
#    ...     ${FALSE}     ${TRUE}     ${TRUE}    ${FALSE}
#    ...     ${expectedStatusCode}
#    IF      ${statusCodeBoolean} == ${FALSE}
#        Fail    Commit composition expected status code ${expectedStatusCode} is different.
#    END
#    [Teardown]     Run Keywords     Delete Composition Using API    AND     TRACE JIRA ISSUE    CDR-539
#
#3.7.2. Test DV_INTERVAL<DV_COUNT> Lower Null - Upper Null - Lower Unb 1 - Upper Unb 1 - Lower Incl 0 - Upper Incl 0 With Lower Upper Constraint
#    [Tags]      Positive    bug
#    [Documentation]     Positive case for DV_INTERVAL<DV_COUNT>
#    ...     Lower Null, Upper Null, Lower Unb 1, Upper Unb 1, Lower Incl 0, Upper Incl 0 With Lower Upper Constraint
#    ...     *See suite documentation to understand what are 1 and 0 values!*
#    ...     - load json file from CANONICAL_JSON folder
#    ...     - set ${dvLower}, ${dvUpper}, ${dvLowerUnb}, ${dvUpperUnb}, ${dvLowerIncl}, ${dvUpperIncl}
#    ...     - commit composition\n- check status code of the commited composition.
#    ...     - Expected status code on commit composition = 201.
#    Set Suite Variable      ${composition_file}    Test_dv_interval_dv_count_lower_upper_constraint.v0__.json
#    Set Suite Variable      ${optFile}             all_types/Test_dv_interval_dv_count_lower_upper_constraint.v0.opt
#    Precondition
#    ${expectedStatusCode}   Set Variable    201
#    ${statusCodeBoolean}    Commit Composition With Modified DV_INTERVAL<DV_COUNT> Values
#    ...     ${NULL}     ${NULL}
#    ...     ${TRUE}     ${TRUE}     ${FALSE}    ${FALSE}
#    ...     ${expectedStatusCode}
#    IF      ${statusCodeBoolean} == ${FALSE}
#        Fail    Commit composition expected status code ${expectedStatusCode} is different.
#    END
#    [Teardown]     Run Keywords     Delete Composition Using API     AND     TRACE JIRA ISSUE    CDR-539
#
#Test DV_INTERVAL<DV_COUNT> Lower 0 - Upper Null - Lower Unb 0 - Upper Unb 1 - Lower Incl 1 - Upper Incl 0 With Lower Upper Constraint
#    [Tags]      Positive    bug
#    [Documentation]     Positive case for DV_INTERVAL<DV_COUNT>
#    ...     Lower 0, Upper Null, Lower Unb 0, Upper Unb 1, Lower Incl 1, Upper Incl 0 With Lower Upper Constraint
#    ...     *See suite documentation to understand what are 1 and 0 values!*
#    ...     - load json file from CANONICAL_JSON folder
#    ...     - set ${dvLower}, ${dvUpper}, ${dvLowerUnb}, ${dvUpperUnb}, ${dvLowerIncl}, ${dvUpperIncl}
#    ...     - commit composition\n- check status code of the commited composition.
#    ...     - Expected status code on commit composition = 201.
#    ${expectedStatusCode}   Set Variable    201
#    ${statusCodeBoolean}    Commit Composition With Modified DV_INTERVAL<DV_COUNT> Values
#    ...     ${0}     ${NULL}
#    ...     ${FALSE}     ${TRUE}     ${TRUE}    ${FALSE}
#    ...     ${expectedStatusCode}
#    IF      ${statusCodeBoolean} == ${FALSE}
#        Fail    Commit composition expected status code ${expectedStatusCode} is different.
#    END
#    [Teardown]     Run Keywords     Delete Composition Using API    AND     TRACE JIRA ISSUE    CDR-539
#
#Test DV_INTERVAL<DV_COUNT> Lower Null - Upper 100 - Lower Unb 1 - Upper Unb 0 - Lower Incl 0 - Upper Incl 1 With Lower Upper Constraint
#    [Tags]      Positive    bug
#    [Documentation]     Positive case for DV_INTERVAL<DV_COUNT>
#    ...     Lower Null, Upper 100, Lower Unb 1, Upper Unb 0, Lower Incl 0, Upper Incl 1 With Lower Upper Constraint
#    ...     *See suite documentation to understand what are 1 and 0 values!*
#    ...     - load json file from CANONICAL_JSON folder
#    ...     - set ${dvLower}, ${dvUpper}, ${dvLowerUnb}, ${dvUpperUnb}, ${dvLowerIncl}, ${dvUpperIncl}
#    ...     - commit composition\n- check status code of the commited composition.
#    ...     - Expected status code on commit composition = 201.
#    ${expectedStatusCode}   Set Variable    201
#    ${statusCodeBoolean}    Commit Composition With Modified DV_INTERVAL<DV_COUNT> Values
#    ...     ${NULL}     ${100}
#    ...     ${TRUE}     ${FALSE}     ${FALSE}    ${TRUE}
#    ...     ${expectedStatusCode}
#    IF      ${statusCodeBoolean} == ${FALSE}
#        Fail    Commit composition expected status code ${expectedStatusCode} is different.
#    END
#    [Teardown]     Run Keywords     Delete Composition Using API    AND     TRACE JIRA ISSUE    CDR-539

*** Keywords ***
Precondition
    Upload OPT    ${optFile}
    create EHR

Commit Composition With Modified DV_INTERVAL<DV_COUNT> Values
    [Arguments]     ${dvLower}=1
    ...             ${dvUpper}=10
    ...             ${dvLowerUnb}=${FALSE}
    ...             ${dvUpperUnb}=${FALSE}
    ...             ${dvLowerIncl}=${TRUE}
    ...             ${dvUpperIncl}=${TRUE}
    ...             ${expectedCode}=201
    Load Json File With Composition
    ${initalJson}           Load Json From File     ${compositionFilePath}
    ${returnedJsonFile}     Change Json KeyValue and Save Back To File
    ...     ${initalJson}   ${dvLower}  ${dvUpper}
    ...     ${dvLowerUnb}   ${dvUpperUnb}   ${dvLowerIncl}  ${dvUpperIncl}
    commit composition      format=CANONICAL_JSON
    ...                     composition=${composition_file}
    ${isStatusCodeEqual}    Run Keyword And Return Status
    ...     Should Be Equal As Strings      ${response.status_code}     ${expectedCode}
    ${isUidPresent}     Run Keyword And Return Status
    ...     Set Test Variable   ${version_uid}    ${response.json()['uid']['value']}
    IF      ${isUidPresent} == ${TRUE}
        @{split_compo_uid}      Split String        ${version_uid}      ::
        Set Suite Variable      ${system_id_with_tenant}    ${split_compo_uid}[1]
        ${short_uid}        Remove String       ${version_uid}    ::${system_id_with_tenant}::1
                            Set Suite Variable   ${versioned_object_uid}    ${short_uid}
    ELSE
        Set Suite Variable   ${versioned_object_uid}    ${None}
    END
    RETURN    ${isStatusCodeEqual}

Change Json KeyValue and Save Back To File
    [Documentation]     Updates DV_INTERVAL<DV_COUNT> lower, upper, lower_unb, upper_unb, lower_incl, upper_incl
    ...     in Composition json, using arguments values.
    ...     Takes 7 arguments:
    ...     1 - jsonContent = Loaded Json content
    ...     2 - value to be on dv_interval.lower.magnitude
    ...     3 - value to be on dv_interval.upper.magnitude
    ...     4 - value to be on dv_interval.lower_unbounded
    ...     5 - value to be on dv_interval.upper_unbounded
    ...     6 - value to be on dv_interval.lower_included
    ...     7 - value to be on dv_interval.upper_included
    [Arguments]     ${jsonContent}      ${dvLowerToUpdate}      ${dvUpperToUpdate}
    ...     ${dvLowerUnbToUpdate}    ${dvUpperUnbToUpdate}      ${dvLowerInclToUpdate}      ${dvUpperInclToUpdate}
    ${dvLowerJsonPath}     Set Variable
    ...     content[0].data.events[0].data.items[0].value.lower.magnitude
    ${dvUpperJsonPath}     Set Variable
    ...     content[0].data.events[0].data.items[0].value.upper.magnitude
    ${dvLowerUnbJsonPath}     Set Variable
    ...     content[0].data.events[0].data.items[0].value.lower_unbounded
    ${dvUpperUnbJsonPath}     Set Variable
    ...     content[0].data.events[0].data.items[0].value.upper_unbounded
    ${dvLowerInclJsonPath}     Set Variable
    ...     content[0].data.events[0].data.items[0].value.lower_included
    ${dvUpperInclJsonPath}     Set Variable
    ...     content[0].data.events[0].data.items[0].value.upper_included
    ${json_object}          Update Value To Json	json_object=${jsonContent}
    ...             json_path=${dvLowerJsonPath}
    ...             new_value=${dvLowerToUpdate}
    ${json_object}          Update Value To Json	json_object=${json_object}
    ...             json_path=${dvUpperJsonPath}
    ...             new_value=${dvUpperToUpdate}
    ${json_object}          Update Value To Json	json_object=${json_object}
    ...             json_path=${dvLowerUnbJsonPath}
    ...             new_value=${dvLowerUnbToUpdate}
    ${json_object}          Update Value To Json	json_object=${json_object}
    ...             json_path=${dvUpperUnbJsonPath}
    ...             new_value=${dvUpperUnbToUpdate}
    ${json_object}          Update Value To Json	json_object=${json_object}
    ...             json_path=${dvLowerInclJsonPath}
    ...             new_value=${dvLowerInclToUpdate}
    ${json_object}          Update Value To Json	json_object=${json_object}
    ...             json_path=${dvUpperInclJsonPath}
    ...             new_value=${dvUpperInclToUpdate}
    ${changedDvLower}   Get Value From Json     ${json_object}      ${dvLowerJsonPath}
    ${changedDvUpper}   Get Value From Json     ${json_object}      ${dvUpperJsonPath}
    ${changedDvLowerUnb}   Get Value From Json      ${json_object}      ${dvLowerUnbJsonPath}
    ${changedDvUpperUnb}   Get Value From Json      ${json_object}      ${dvUpperUnbJsonPath}
    ${changedDvLowerIncl}   Get Value From Json     ${json_object}      ${dvLowerInclJsonPath}
    ${changedDvUpperIncl}   Get Value From Json     ${json_object}      ${dvUpperInclJsonPath}
    ${json_str}     Convert JSON To String    ${json_object}
    Create File     ${compositionFilePath}    ${json_str}
    RETURN    ${compositionFilePath}