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

Resource        ../suite_settings.robot
Resource        ehr_keywords.robot


*** Variables ***
${AQL_EXPRESSIONS_DATA_SETS}    ${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/aql/statements
${TEMPLATES_DATA_SETS}          ${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/aql/data_load/opts
${EHR_DATA_SETS}                ${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/ehr/valid
${COMPOSITIONS_DATA_SETS}       ${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/aql/data_load/compositions


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
    ...                 - Stores response in 4 vars: resp_body, resp_body_query, resp_body_columns, resp_body_rows
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

Upload OPT For AQL
    [Documentation]     Uploads OPT for AQL tests.
    ...                 - Requires 1 mandatory argument template_file.
    ...                 - template_file - to be specified with .opt extension.
    ...                 - Checks if 200 or 201 was returned. If 409 is returned, keyword is passed (template already exists).
    ...                 - If 400, 500 or any other code is returned, keyword must fail.
    [Arguments]     ${template_file}
    prepare new request session    XML      Prefer=return=representation
    Create Session      ${SUT}    ${BASEURL}    debug=2   headers=${headers}
    ${file}             Get Binary File         ${TEMPLATES_DATA_SETS}/${template_file}
    ${xml}              Parse Xml               ${file}
                        ${template_id}    Get Element Text    ${xml}    xpath=./template_id/value
                        Set Suite Variable      ${file}         ${file}
                        Set Suite Variable      ${expected}     ${xml}
                        Set Suite Variable      ${template_id}  ${template_id}
    ${resp}             POST On Session      ${SUT}     /definition/template/adl1.4
                        ...     expected_status=anything    data=${file}    headers=${headers}
                        Set Suite Variable      ${response}     ${resp}
                        Set Suite Variable      ${response_code}    ${response.status_code}
    Return From Keyword If      '${response_code}' == '409'
    ${expected_codes_list}      Create List     ${200}     ${201}
    Should Contain      ${expected_codes_list}      ${response_code}    Upload OPT returned code=${response_code}.

Create EHR For AQL
    [Documentation]     Create EHR with EHR_Status and other details, so it can contain correct subject object.
    prepare new request session    JSON      Prefer=return=representation
    create new EHR with ehr_status  ${EHR_DATA_SETS}/000_ehr_status_with_other_details.json
                        Integer     response status     201
    ${ehr_id_obj}       Object      response body ehr_id
    ${ehr_id_value}     String      response body ehr_id value
                        Set Suite Variable      ${ehr_id_obj}     ${ehr_id_obj}
                        Set Suite Variable      ${ehr_id}         ${ehr_id_value}[0]

Admin Delete EHR For AQL
    [Documentation]     Delete EHR using ADMIN endpoint.
    ...                 - It must delete all objects linked to EHR as well as the EHR itself.
    ...                 - Takes 1 optional argument {ehr_id}.
    ...                 - Dependent of keyword 'Create EHR For AQL', due to {ehr_id} var.
    ...                 - Expects *204*.
    [Arguments]     ${ehr_id}=${ehr_id}
    prepare new request session    JSON
    Create Session      ${SUT}    ${ADMIN_BASEURL}    debug=2   headers=${headers}
    ${resp}             DELETE On Session      ${SUT}     /ehr/${ehr_id}
                        ...     expected_status=anything
                        Should Be Equal As Strings      ${resp.status_code}     ${204}






