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
${EHR_STATUS_DATA_SETS_AQL}     ${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/aql/data_load/ehrs
${COMPOSITIONS_DATA_SETS}       ${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/aql/data_load/compositions
${EXPECTED_JSON_DATA_SETS}      ${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/aql/fields_and_results


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

Set AQL And Execute Ad Hoc Query
    [Documentation]     Setup AQL for POST request body and send Ad Hoc Query.
    ...                 - Set resp_body_actual, actual_rows, columns_length, rows_length.
    ...                 - Takes 1 mandatory arg query_expr, to be provided directly AQL statement without "q":
    ...                 - Takes 1 optional arg parameter, to be provided in case query contains params
    ...                 - Example: SELECT c FROM COMPOSITION c
    [Arguments]     ${query_expr}   ${parameter}=${EMPTY}
    IF      '''${parameter}''' == '''${EMPTY}'''
        ${test_data}    Set Variable    {"q":"${query_expr}"}
    ELSE
        ${test_data}    Set Variable    {"q":"${query_expr}","query_parameters":${parameter}}
    END
    Send Ad Hoc Request     aql_body=${test_data}
    Set Test Variable       ${resp_body_actual}     ${resp_body}
    #${actual_rows}      Set Variable    ${resp_body_rows[0]}
    ${columns_length}   Get Length      ${resp_body_columns}

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
                        ##IF to be removed when all AQL features are implemented.
                        IF      '${resp.status_code}' == '${400}'
                            ${notImplMsgStatus}         Run Keyword And Return Status   Should Contain
                            ...     ${resp.json()["message"]}   Not implemented
                            ${notSupportedMsgStatus}    Run Keyword And Return Status   Should Contain
                            ...     ${resp.json()["message"]}   is not supported
                            ${unclearIfTargetsCompoMsgStatus}    Run Keyword And Return Status   Should Contain
                            ...     ${resp.json()["message"]}   targets a COMPOSITION or EHR_STATUS
                            Skip If     '${notImplMsgStatus}' == '${TRUE}'
                            ...     Skipped due to 400 and Not implemented.
                            Pass Execution If   '${notSupportedMsgStatus}' == '${TRUE}' or '${unclearIfTargetsCompoMsgStatus}' == '${TRUE}'
                            ...     ${resp.json()["message"]}
                            #Pass On Expected Message    ${resp.json()["message"]}
                        END
                        Should Be Equal As Strings      ${resp.status_code}     ${200}      msg=${resp.status_code},${resp.json()}
                        Set Test Variable   ${resp_status_code}    ${resp}
                        Set Test Variable   ${resp_body}    ${resp.json()}
                        Set Test Variable   ${resp_body_query}    ${resp_body['q']}
                        Set Test Variable   ${resp_body_columns}    ${resp_body['columns']}
                        #Log     ${resp_body_query}
                        #Log     ${resp_body_columns}
                        #Log     ${resp_body_rows}

Pass On Expected Message
    [Documentation]     Pass test if expected_msg is the same as in error message
    ...         returned in AQL execution response.
    ...         {type} - to be set as test variable at the level of test
    ...         Takes 1 mandatory arg {resp_err_msg} - message returned in AQL execution response.
    [Arguments]     ${resp_err_msg}
    ${expected_msg}     Set Variable
    ...     It is unclear if ${type} targets a COMPOSITION or EHR_STATUS
    IF      '${resp_err_msg}' == '${expected_msg}'
        Pass Execution      ${expected_msg} - was returned.
    END

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
    ...     Takes 1 optional arg {ehr_id}, with randomly generated id at Test/Keyword level.
    ...     Keyword to generate ehr_id is 'generate random ehr_id', located inside ehr_keywords.robot
    [Arguments]     ${ehr_id}=${NONE}
    prepare new request session    JSON      Prefer=return=representation
    IF      '${ehr_id}' != '${NONE}'
        ${ehr_status_json}  Load JSON From File     ${EHR_DATA_SETS}/000_ehr_status_with_other_details.json
        Update Value To Json    ${ehr_status_json}    $.subject.external_ref.id.value
        ...    ${{str(uuid.uuid4())}}
        Update Value To Json    ${ehr_status_json}    $.subject.external_ref.namespace
        ...    namespace_${{''.join(random.choices(string.digits, k=7))}}
        create new EHR by ID    ehr_id=${ehr_id}   ehr_status_json=${ehr_status_json}
    ELSE
        create new EHR with ehr_status  ${EHR_DATA_SETS}/000_ehr_status_with_other_details.json
    END
                        Integer     response status     201
    ${ehr_id_obj}       Object      response body ehr_id
    ${ehr_id_value}     String      response body ehr_id value
                        Set Suite Variable      ${ehr_id_obj}     ${ehr_id_obj}
                        Set Suite Variable      ${ehr_id}         ${ehr_id_value}[0]

Create EHR For AQL With Custom EHR Status
    [Documentation]     Create EHR with custom EHR_STATUS, filename provided in mandatory arg {file_name}.
    [Arguments]     ${file_name}
    prepare new request session    JSON      Prefer=return=representation
    create new EHR with ehr_status      ${EHR_STATUS_DATA_SETS_AQL}/${file_name}
                        Integer     response status     201
    ${ehr_id_obj}       Object      response body ehr_id
    ${ehr_id_value}     String      response body ehr_id value
    ${ehr_status_subject_external_ref_value}    String    response body ehr_status subject external_ref id value
    ${ehr_status_subject_external_ref_namespace}    String      response body ehr_status subject external_ref namespace
                        Set Suite Variable      ${ehr_id_obj}     ${ehr_id_obj}
                        Set Suite Variable      ${ehr_id}         ${ehr_id_value}[0]
                        Set Suite Variable      ${subject_external_ref_value}
                        ...     ${ehr_status_subject_external_ref_value}[0]
                        Set Suite Variable      ${subject_external_ref_namespace}
                        ...     ${ehr_status_subject_external_ref_namespace}[0]

Commit Composition For AQL
    [Documentation]     Create Composition for AQL checks.
    ...                 - Depends on 'Upload OPT For AQL' keyword, due to template_id.
    ...                 - Composition will be sent in CANONICAL JSON format.
    ...                 - Takes 1 mandatory arg composition_file, to be provided as follows:
    ...                 - composition_file_name.json
    [Arguments]         ${composition_file}
    prepare new request session    JSON      Prefer=return=representation
    Set To Dictionary   ${headers}   openEHR-TEMPLATE_ID=${template_id}
    Create Session      ${SUT}    ${BASEURL}    debug=2
     ...                 auth=${CREDENTIALS}    verify=True
    ${file}             Get Binary File     ${COMPOSITIONS_DATA_SETS}/${composition_file}
    ${resp}             POST On Session     ${SUT}   /ehr/${ehr_id}/composition
                        ...     expected_status=anything    data=${file}    headers=${headers}
                        Should Be Equal As Strings      ${resp.status_code}    ${201}
    Set Suite Variable   ${response}     ${resp}
    Set Suite Variable   ${composition_uid}      ${resp.json()['uid']['value']}
    ${short_uid}        Remove String       ${composition_uid}      ::${CREATING_SYSTEM_ID}::1
    Set Suite Variable   ${composition_short_uid}    ${short_uid}

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






