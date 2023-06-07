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
    #${query_expr}   Get File     ${AQL_EXPRESSIONS_DATA_SETS}/dummy_aql_1.txt
    #${actual}   Set Variable    expected_name
    #${replaced_query}   Replace Variables   ${query_expr}
    ${replaced_query}   Set Variable   SELECT c/uid/value as COMPO_ID_VAL,e/ehr_id/value FROM EHR e CONTAINS COMPOSITION c
    log     ${replaced_query}
    ${test_data}    Set Variable    {"q":"${replaced_query}"}
    Send Ad Hoc Request    aql_body=${test_data}
    ${actual}   Set Variable    ${resp_body_rows[0]}
    ${columns_length}   Get Length      ${resp_body_columns}
    ${rows_length}      Get Length      ${resp_body_rows}
    IF      '${expected}' != '${actual}'
        Fail
    END


Send Ad Hoc Request
    [Documentation]     Prepare and send Ad Hoc request to {baseurl}/query/aql.
    ...                 - Method: *POST*, expects: *200*.
    ...                 - Takes 1 mandatory argument: aql_body, to be provided in format {"q":"${query}"}
    ...                 - Stores response_body.json in 4 vars: resp_body, resp_body_query, resp_body_columns, resp_body_rows
    [Arguments]     ${aql_body}
    &{headers}          Create Dictionary   Content-Type=application/json
    Create Session      ${SUT}      ${BASEURL}
    ...     debug=2     headers=${headers}      verify=True
    ${resp}             POST On Session     ${SUT}   /query/aql   expected_status=anything
                        ...                 data=${aql_body}
                        Should Be Equal As Strings      ${resp.status_code}     ${200}
                        Set Test Variable   ${resp_status_code}    ${resp}
                        Set Test Variable   ${resp_body}    ${resp.json()}
                        Set Test Variable   ${resp_body_query}    ${resp_body['q']}
                        Set Test Variable   ${resp_body_columns}    ${resp_body['columns']}
                        Set Test Variable   ${resp_body_rows}    ${resp_body['rows'][0]}    #due to [[ ]]
                        #Log     ${resp_body_query}
                        #Log     ${resp_body_columns}
                        #Log     ${resp_body_rows}



