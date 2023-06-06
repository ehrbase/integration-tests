# Copyright (c) 2023 Vladislav Ploaia (Vitagroup - CDR Core Team).
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
Documentation    AQL checks keywords

Resource   ../suite_settings.robot


*** Variables ***
${AQL_EXPRESSIONS_DATA_SETS}     ${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/aql/statements


*** Keywords ***
Execute Ad Hoc Query
    [Arguments]     ${path}     ${expected}
    ${query_expr}   Get File     ${AQL_EXPRESSIONS_DATA_SETS}/dummy_aql_1.txt
    ${actual}   Set Variable    expected_name
    ${replaced_query}   Replace Variables    ${query_expr}
    log     ${replaced_query}
    IF      '${expected}' != '${actual}'
        Fail
    END

