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
${VALID CONTRI DATA SETS}       ${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/contributions/valid
${FOLDERS_DATA_SETS}            ${PROJECT_ROOT}/tests/robot/_resources/test_data_sets/aql/data_load/folder


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

Send Ad Hoc Request Through GET
    [Arguments]     ${q_param}     ${req_headers}=default
    IF      '''${req_headers}''' != '''default'''
        #${req_headers} should contain data in dictionary format
        &{headers}      Set Variable    ${req_headers}
    ELSE
        &{headers}      Create Dictionary   Content-Type=application/json
    END
    Create Session      ${SUT}      ${BASEURL}
    ...     debug=2     headers=${headers}      verify=True
    ${query_params}     Set Variable    q=${q_param}
    ${resp}             GET On Session     ${SUT}   /query/aql   expected_status=anything
                        ...                 params=${query_params}
                        Should Be Equal As Strings      ${resp.status_code}     ${200}      msg=${resp.status_code},${resp.json()}
                        Set Test Variable   ${resp_status_code}     ${resp}
                        Set Test Variable   ${resp_body}    ${resp.json()}
                        Set Test Variable   ${resp_body_query}      ${resp_body['q']}
                        Set Test Variable   ${resp_body_columns}    ${resp_body['columns']}

Send Execute Stored Query Request Through GET

Send Ad Hoc Request
    [Documentation]     Prepare and send Ad Hoc request to {baseurl}/query/aql.
    ...                 - Method: *POST*, expects: *200*.
    ...                 - Takes 1 mandatory argument: aql_body, to be provided in format {"q":"${query}"}
    ...                 - Stores response in 4 vars: resp_body, resp_body_query, resp_body_columns, resp_body_rows
    [Arguments]     ${aql_body}     ${req_headers}=default

    IF      '''${req_headers}''' != '''default'''
        #${req_headers} should contain data in dictionary format
        &{headers}      Set Variable    ${req_headers}
    ELSE
        &{headers}      Create Dictionary   Content-Type=application/json
    END
    IF      '${AUTH_TYPE}' == 'BASIC' or '${AUTH_TYPE}' == 'OAUTH'
        Set To Dictionary       ${headers}      &{authorization}
    END
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
                        Set Test Variable   ${resp_status_code}     ${resp}
                        Set Test Variable   ${resp_body}    ${resp.json()}
                        Set Test Variable   ${resp_body_query}      ${resp_body['q']}
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
        ${ehr_status_json}  Update Value To Json    ${ehr_status_json}    $.subject.external_ref.id.value
        ...    ${{str(uuid.uuid4())}}
        ${ehr_status_json}  Update Value To Json    ${ehr_status_json}    $.subject.external_ref.namespace
        ...    namespace_${{''.join(random.choices(string.digits, k=7))}}
        create new EHR by ID    ehr_id=${ehr_id}   ehr_status_json=${ehr_status_json}
    ELSE
        create new EHR with ehr_status  ${EHR_DATA_SETS}/000_ehr_status_with_other_details.json
    END
    Status Should Be    201
    Set Suite Variable      ${ehr_id_obj}       ${resp.json()['ehr_id']}
    Set Suite Variable      ${ehr_id_value}     ${resp.json()['ehr_id']['value']}
    Set Suite Variable      ${system_id_with_tenant}     ${resp.json()['system_id']['value']}
    Set Suite Variable      ${ehr_id}     ${ehr_id_value}

Create EHR For AQL With Custom EHR Status
    [Documentation]     Create EHR with custom EHR_STATUS, filename provided in mandatory arg {file_name}.
    [Arguments]     ${file_name}
    prepare new request session    JSON      Prefer=return=representation
    create new EHR with ehr_status      ${EHR_STATUS_DATA_SETS_AQL}/${file_name}
    Status Should Be    201
    Set Suite Variable      ${ehr_id_obj}       ${resp.json()['ehr_id']}
    Set Suite Variable      ${ehr_id_value}     ${resp.json()['ehr_id']['value']}
    Set Suite Variable      ${ehr_id_obj}     ${ehr_id_obj}
    Set Suite Variable      ${ehr_status_uid}     ${response.json()['ehr_status']['uid']['value']}
    Set Suite Variable      ${ehr_id}         ${ehr_id_value}
    Set Suite Variable      ${subject_external_ref_value}
    ...     ${response.json()['ehr_status']['subject']['external_ref']['id']['value']}
    Set Suite Variable      ${subject_external_ref_namespace}
    ...     ${response.json()['ehr_status']['subject']['external_ref']['namespace']}

Commit Composition For AQL
    [Documentation]     Create Composition for AQL checks.
    ...                 - Depends on 'Upload OPT For AQL' keyword, due to template_id.
    ...                 - Composition will be sent in CANONICAL JSON format.
    ...                 - Takes 1 mandatory arg composition_file, to be provided as follows:
    ...                 - composition_file_name.json
    [Arguments]         ${composition_file}     ${format}=CANONICAL_JSON
    prepare new request session    JSON      Prefer=return=representation
    Set To Dictionary   ${headers}   openEHR-TEMPLATE_ID=${template_id}
    IF      '${format}' == 'CANONICAL_JSON'
        Create Session      ${SUT}      ${BASEURL}      debug=2
                            ...     verify=True     #auth=${CREDENTIALS}
    ELSE IF     '${format}' == 'FLAT'
        Create Session      ${SUT}      ${ECISURL}      debug=2
                            ...     verify=True     #auth=${CREDENTIALS}
        &{params}       Create Dictionary
        ...     format=FLAT     ehrId=${ehr_id}     templateId=${template_id}
    END
    ##
    ${is_var_exists}      Run Keyword And Return Status
    ...     Variable Should Exist    ${system_id_with_tenant}
    ${temp_file_content}    Get File    ${COMPOSITIONS_DATA_SETS}/${composition_file}
    ${is_var_present_in_file}   Run Keyword And Return Status
    ...     Should Contain    ${temp_file_content}    \${system_id_with_tenant}
    IF  '${is_var_exists}' == '${TRUE}' and '${is_var_present_in_file}' == '${TRUE}'
        ${replaced_file_str}    Replace String      ${temp_file_content}
        ...     \${system_id_with_tenant}   ${system_id_with_tenant}
        ${file}         Set Variable        ${replaced_file_str}
    ELSE
        ${file_tmp}     Get Binary File     ${COMPOSITIONS_DATA_SETS}/${composition_file}
        ${file}         Set Variable        ${file_tmp}
    END
    ##
    IF      '${format}' == 'FLAT'
        ${resp}     POST On Session     ${SUT}      composition
        ...     params=${params}    expected_status=anything
        ...     data=${file}        headers=${headers}
        Should Be Equal As Strings      ${resp.status_code}    ${201}
        Set Suite Variable   ${composition_uid}      ${resp.json()['compositionUid']}
    ELSE
        ${resp}     POST On Session     ${SUT}      /ehr/${ehr_id}/composition
        ...     expected_status=anything    data=${file}    headers=${headers}
        Should Be Equal As Strings      ${resp.status_code}    ${201}
        Set Suite Variable   ${composition_uid}      ${resp.json()['uid']['value']}
    END
    Set Suite Variable   ${response}     ${resp}
    @{split_compo_uid}      Split String        ${composition_uid}      ::
    Set Suite Variable      ${system_id_with_tenant}    ${split_compo_uid}[1]
    Set Suite Variable      ${composition_short_uid}    ${split_compo_uid}[0]

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

Update EHR Status For EHR
    [Documentation]     Update EHR Status of EHR with given `ehr_id`.
    [Arguments]     ${ehr_id}   ${ehrstatus_uid}    ${ehr_status_file}
    &{headers}      Create Dictionary
    ...     Accept=application/json     Content-Type=application/json
    ...     Prefer=return=representation    If-Match=${ehrstatus_uid}
    ${ehr_status_json}      Load JSON From File    ${EHR_STATUS_DATA_SETS_AQL}/${ehr_status_file}
    Log     ${ehr_status_json}
    ${resp}         PUT On Session    ${SUT}    /ehr/${ehr_id}/ehr_status    json=${ehr_status_json}
                    ...         headers=${headers}      expected_status=anything
                    Set Suite Variable    ${response}    ${resp}
                    Should Be Equal     ${response.status_code}     ${200}

Get EHR Status Time Committed
    [Arguments]     ${ehr_status_uid}
    ${query_to_get_time_committed}      Catenate
    ...     SELECT cv/commit_audit/time_committed/value
    ...     FROM VERSION cv[LATEST_VERSION]
    ...     CONTAINS EHR_STATUS s
    ...     WHERE cv/uid/value = '${ehr_status_uid}'
    Set AQL And Execute Ad Hoc Query    ${query_to_get_time_committed}
    RETURN    ${resp_body['rows'][0][0]}

Get Composition Time Committed
    [Arguments]     ${composition_uid}
    ${query_to_get_time_committed}      Catenate
    ...     SELECT cv/commit_audit/time_committed/value
    ...     FROM VERSION cv[LATEST_VERSION]
    ...     CONTAINS COMPOSITION s
    ...     WHERE cv/uid/value = '${composition_uid}'
    Set AQL And Execute Ad Hoc Query    ${query_to_get_time_committed}
    RETURN    ${resp_body['rows'][0][0]}

Get Observation Time Committed
    [Arguments]     ${composition_uid}
    ${query_to_get_time_committed}      Catenate
    ...     SELECT cv/commit_audit/time_committed/value
    ...     FROM VERSION cv[LATEST_VERSION]
    ...     CONTAINS OBSERVATION s
    ...     WHERE cv/uid/value = '${composition_uid}'
    Set AQL And Execute Ad Hoc Query    ${query_to_get_time_committed}
    RETURN    ${resp_body['rows'][0][0]}

Commit Contribution For AQL
    [Arguments]     ${valid_test_data_set}
                    ${file}     Load JSON from File     ${VALID CONTRI DATA SETS}/${valid_test_data_set}
                    Set Suite Variable    ${test_data}    ${file}
                    prepare new request session     Prefer=return=representation
                    ${resp}     POST On Session     ${SUT}  /ehr/${ehr_id}/contribution   expected_status=anything
                                ...     json=${test_data}   headers=${headers}
                    Set Suite Variable      ${response}     ${resp}
                    Set Suite Variable      ${body}     ${response.json()}
                    Set Suite Variable      ${contribution_uid}     ${body['uid']['value']}
                    Set Suite Variable      ${versions}     ${body['versions']}
                    Should Be Equal     ${response.status_code}     ${201}

Update Composition For AQL
    [Arguments]         ${new_composition}
    ${file}     Get Binary File     ${COMPOSITIONS_DATA_SETS}/${new_composition}
    Delete All Sessions
    &{headers}          Create Dictionary   Content-Type=application/json
                        ...                 Accept=application/json
                        ...                 Prefer=return=representation
                        ...                 If-Match=${composition_uid}
    Create Session      ${SUT}      ${BASEURL}      debug=2
    ...                 verify=True         headers=${headers}
    @{split_compo_id}   Split String        ${composition_uid}      ::
    ${composition_id}   Set Variable        ${split_compo_id}[0]
    &{params}           Create Dictionary   ehr_id=${ehr_id}    composition_id=${composition_id}
    ${resp}             PUT On Session      ${SUT}          /ehr/${ehr_id}/composition/${composition_id}
    ...                 data=${file}    headers=${headers}      params=${params}    expected_status=anything
    Set Suite Variable       ${response}             ${resp}
    Set Suite Variable       ${updated_version_composition_uid}      ${resp.json()['uid']['value']}
    Should Be Equal As Strings      ${resp.status_code}     ${200}

Delete Composition For AQL
    [Arguments]         ${composition_uid}
    ${resp}     Delete On Session   ${SUT}  /ehr/${ehr_id}/composition/${composition_uid}
    ...         expected_status=anything    headers=${headers}
    Set Suite Variable      ${response}     ${resp}
    Status Should Be    204
    ${del_version_uid}      Get Substring           ${resp.headers['ETag']}    1    -1
    Set Suite Variable      ${del_version_uid}      ${del_version_uid}

Create Directory For AQL
    [Arguments]     ${valid_test_data_set}      ${has_robot_vars}=${FALSE}
    IF      '${has_robot_vars}' == '${TRUE}'
        ${json_str}     Get File     ${FOLDERS_DATA_SETS}/${valid_test_data_set}
        ${json_str_replaced}    Replace Variables   ${json_str}
        ${json_converted}       Evaluate    json.loads('''${json_str_replaced}''')    json
        ${json}     Set Variable   ${json_converted}
    ELSE
        ${json}     Load JSON From File     ${FOLDERS_DATA_SETS}/${valid_test_data_set}
    END
    Set Suite Variable      ${test_data}    ${json}
    prepare new request session    JSON
    ...     Prefer=return=representation
    ${resp}     POST On Session     ${SUT}   /ehr/${ehr_id}/directory   expected_status=anything
                ...                 json=${test_data}
                ...                 headers=${headers}
    Set Suite Variable      ${response}     ${resp}
    Status Should Be        201
    Set Suite Variable      ${folder_uid}   ${response.json()['uid']['value']}


Set Debug Options In Dict
    [Arguments]     ${dry_run}=false     ${exec_sql}=false   ${query_plan}=false
    &{debug_headers}    Create Dictionary
    ...     Content-Type=application/json
    ...     EHRbase-AQL-DRY_RUN=${dry_run}
    ...     EHRbase-AQL-EXECUTED_SQL=${exec_sql}
    ...     EHRbase-AQL-QUERY_PLAN=${query_plan}
    Set Test Variable   ${dry_run}      ${dry_run}
    Set Test Variable   ${exec_sql}     ${exec_sql}
    Set Test Variable   ${query_plan}   ${query_plan}
    RETURN        ${debug_headers}

Get File And Replace Dynamic Vars In File And Store As String
    # Reads file identified by full path provided to test_data_file
    # Replace all variables from the readed file content if it contains any
    # Returns json with replaced variables
    [Arguments]     ${test_data_file}
    ${json_str}     Get File     ${test_data_file}
    ${json_str_replaced}    Replace Variables   ${json_str}
    Log     ${json_str_replaced}
    RETURN    ${json_str_replaced}