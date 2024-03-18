# Copyright (c) 2024 Vladislav Ploaia (Vitagroup - CDR Core Team).
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
Documentation   Migrated EHRSCAPE TESTS
...             Covers endpoints migrated from EHRSCAPE to OpenEHR (template example, webtemplate, flat and structured)

Resource        ../_resources/keywords/composition_keywords.robot
Resource        ../_resources/keywords/admin_keywords.robot
Resource        ../_resources/keywords/ehr_keywords.robot

Suite Setup       Precondition


*** Variables ***
&{headers_flat_content_type_dict}         Prefer=return=representation   Accept=application/json     Content-Type=application/openehr.wt.flat.schema+json
&{headers_json_dict}        Prefer=return=representation    Accept=application/json     Content-Type=application/json
&{headers_xml_dict}         Prefer=return=representation    Accept=application/xml      Content-Type=application/xml
&{headers_structured_content_type_dict}     Prefer=return=representation    Accept=application/json     Content-Type=application/openehr.wt.structured.schema+json


*** Test Cases ***
1. Create Compo FLAT EHRSCAPE Migrated
    Commit Composition OpenEHR       composition=family_history__.json   format=FLAT
    Should Be Equal     ${resp.status_code}     ${201}
    Set Suite Variable  ${compo_uid}        ${resp.json()['family_history/_uid']}
    @{compo_uid_splitted}   Split String    ${compo_uid}    ::
    Set Suite Variable  ${compo_id}         ${compo_uid_splitted}[0]
    Set Suite Variable  ${system_id_with_tenant}    ${compo_uid_splitted}[1]
    Headers Checks Composition

2. Create Compo JSON EHRSCAPE Migrated
    Commit Composition OpenEHR      composition=family_history__.json   format=JSON
    Should Be Equal     ${resp.status_code}     ${201}
    Set Test Variable       ${compo_uid}    ${resp.json()['uid']['value']}
    @{compo_uid_splitted}   Split String    ${compo_uid}    ::
    Set Test Variable       ${compo_id}     ${compo_uid_splitted}[0]
    Should Be Equal     ${compo_uid_splitted}[1]    ${system_id_with_tenant}
    Should Be Equal     ${compo_uid_splitted}[2]    1
    Headers Checks Composition

3. Create Compo XML EHRSCAPE Migrated
    Commit Composition OpenEHR      composition=family_history__.xml   format=XML
    Should Be Equal     ${resp.status_code}     ${201}
    ${xresp}        Parse Xml       ${resp.text}
    ${compo_uid}    Get Element Text        ${xresp}    uid/value
    @{compo_uid_splitted}   Split String    ${compo_uid}    ::
    Set Test Variable       ${compo_id}     ${compo_uid_splitted}[0]
    Headers Checks Composition

4. Create Compo STRUCTURED EHRSCAPE Migrated
    Commit Composition OpenEHR      composition=family_history__.json   format=STRUCTURED
    Should Be Equal     ${resp.status_code}     ${201}
    Set Test Variable       ${compo_uid}    ${resp.json()['family_history']['_uid']}
    @{compo_uid_splitted}   Split String    ${compo_uid}[0]    ::
    Set Test Variable       ${compo_id}     ${compo_uid_splitted}[0]
    Should Be Equal     ${compo_uid_splitted}[1]    ${system_id_with_tenant}
    Should Be Equal     ${compo_uid_splitted}[2]    1
    Headers Checks Composition

5. Update Compo FLAT EHRSCAPE Migrated
    Update Composition OpenEHR       composition=family_history.v2__.json   format=FLAT
    Should Be Equal     ${resp.status_code}     ${200}
    @{compo_uid_splitted}   Split String    ${resp.json()['family_history/_uid']}    ::
    Should Be Equal     ${compo_uid_splitted}[2]    2
    Headers Checks Composition      compo_uid_version=2

6. Update Compo JSON EHRSCAPE Migrated
    Set Test Variable       ${compo_uid}    ${compo_id}::${system_id_with_tenant}::2
    Update Composition OpenEHR       composition=family_history.v2__.json   format=JSON
    Should Be Equal     ${resp.status_code}     ${200}
    ${compo_uid}    Set Variable        ${resp.json()['uid']['value']}
    @{compo_uid_splitted}   Split String    ${compo_uid}    ::
    Set Test Variable       ${compo_id}     ${compo_uid_splitted}[0]
    Should Be Equal     ${compo_uid_splitted}[1]    ${system_id_with_tenant}
    Should Be Equal     ${compo_uid_splitted}[2]    3
    Headers Checks Composition      compo_uid_version=3

7. Update Compo XML EHRSCAPE Migrated
    Set Test Variable       ${compo_uid}    ${compo_id}::${system_id_with_tenant}::3
    Update Composition OpenEHR       composition=family_history.v2__.xml   format=XML
    Should Be Equal     ${resp.status_code}     ${200}
    ${xresp}        Parse Xml       ${resp.text}
    ${compo_uid}    Get Element Text        ${xresp}    uid/value
    @{compo_uid_splitted}   Split String    ${compo_uid}    ::
    Should Be Equal     ${compo_uid_splitted}[1]    ${system_id_with_tenant}
    Should Be Equal     ${compo_uid_splitted}[2]    4
    Set Test Variable       ${compo_id}     ${compo_uid_splitted}[0]
    Headers Checks Composition      compo_uid_version=4

8. Update Compo STRUCTURED EHRSCAPE Migrated
    Set Test Variable       ${compo_uid}    ${compo_id}::${system_id_with_tenant}::4
    Update Composition OpenEHR       composition=family_history.v2__.json   format=STRUCTURED
    Should Be Equal     ${resp.status_code}     ${200}
    Set Test Variable   ${compo_uid}    ${resp.json()['family_history']['_uid']}
    @{compo_uid_splitted}   Split String    ${compo_uid}[0]    ::
    Set Test Variable       ${compo_id}     ${compo_uid_splitted}[0]
    Should Be Equal     ${compo_uid_splitted}[1]    ${system_id_with_tenant}
    Should Be Equal     ${compo_uid_splitted}[2]    5
    Headers Checks Composition      compo_uid_version=5

9. Update Compo STRUCTURED Content Type EHRSCAPE Migrated
    Set Test Variable       ${compo_uid}    ${compo_id}::${system_id_with_tenant}::5
    Update Composition OpenEHR       composition=family_history.v2__.json   format=STRUCTURED_CONTENT_TYPE
    Should Be Equal     ${resp.status_code}     ${200}
    ${compo_uid}    Set Variable        ${resp.json()['uid']['value']}
    @{compo_uid_splitted}   Split String    ${compo_uid}    ::
    Set Test Variable       ${compo_id}     ${compo_uid_splitted}[0]
    Should Be Equal     ${compo_uid_splitted}[1]    ${system_id_with_tenant}
    Should Be Equal     ${compo_uid_splitted}[2]    6
    Headers Checks Composition      compo_uid_version=6

10. Update Compo FLAT Content Type EHRSCAPE Migrated
    Set Test Variable       ${compo_uid}    ${compo_id}::${system_id_with_tenant}::6
    Update Composition OpenEHR       composition=family_history.v2__.json   format=FLAT_CONTENT_TYPE
    Should Be Equal     ${resp.status_code}     ${200}
    ${compo_uid}    Set Variable        ${resp.json()['uid']['value']}
    @{compo_uid_splitted}   Split String    ${compo_uid}    ::
    Set Test Variable       ${compo_id}     ${compo_uid_splitted}[0]
    Should Be Equal     ${compo_uid_splitted}[1]    ${system_id_with_tenant}
    Should Be Equal     ${compo_uid_splitted}[2]    7
    Headers Checks Composition      compo_uid_version=7

11. Get Compo FLAT EHRSCAPE Migrated
    Set Test Variable       ${compo_uid}    ${compo_id}::${system_id_with_tenant}::7
    Get Versioned Composition OpenEHR
    Should Be Equal     ${resp.status_code}     ${200}
    Set Test Variable   ${compo_uid}    ${resp.json()['family_history/_uid']}
    @{compo_uid_splitted}   Split String    ${compo_uid}    ::
    Set Test Variable       ${compo_id}     ${compo_uid_splitted}[0]
    Should Be Equal     ${compo_uid_splitted}[1]    ${system_id_with_tenant}
    Should Be Equal     ${compo_uid_splitted}[2]    7
    Log     ${resp.headers}
    Dictionary Should Contain Item      ${resp.headers}     ETag    "${compo_uid}"
    Dictionary Should Contain Item      ${resp.headers}     EHRBase-Template-ID     ${template_id}

12. Get Compo JSON EHRSCAPE Migrated
    Set Test Variable       ${compo_uid}    ${compo_id}::${system_id_with_tenant}::6
    Get Versioned Composition OpenEHR   format=JSON
    Should Be Equal     ${resp.status_code}     ${200}
    ${compo_uid}    Set Variable        ${resp.json()['uid']['value']}
    @{compo_uid_splitted}   Split String    ${compo_uid}    ::
    Set Test Variable       ${compo_id}     ${compo_uid_splitted}[0]
    Should Be Equal     ${compo_uid_splitted}[1]    ${system_id_with_tenant}
    Should Be Equal     ${compo_uid_splitted}[2]    6
    Dictionary Should Contain Item      ${resp.headers}     ETag    "${compo_uid}"
    Dictionary Should Contain Item      ${resp.headers}     EHRBase-Template-ID     ${template_id}

13. Get Compo XML EHRSCAPE Migrated
    Set Test Variable       ${compo_uid}    ${compo_id}::${system_id_with_tenant}::5
    Get Versioned Composition OpenEHR   format=XML
    Should Be Equal     ${resp.status_code}     ${200}
    ${xresp}        Parse Xml       ${resp.text}
    ${compo_uid}    Get Element Text        ${xresp}    uid/value
    @{compo_uid_splitted}   Split String    ${compo_uid}    ::
    Should Be Equal     ${compo_uid_splitted}[1]    ${system_id_with_tenant}
    Should Be Equal     ${compo_uid_splitted}[2]    5
    Set Test Variable       ${compo_id}     ${compo_uid_splitted}[0]
    Dictionary Should Contain Item      ${resp.headers}     ETag    "${compo_uid}"
    Dictionary Should Contain Item      ${resp.headers}     EHRBase-Template-ID     ${template_id}

14. Get Compo STRUCTURED EHRSCAPE Migrated
    Set Test Variable       ${compo_uid}    ${compo_id}::${system_id_with_tenant}::4
    Get Versioned Composition OpenEHR   format=STRUCTURED
    Should Be Equal     ${resp.status_code}     ${200}
    Set Test Variable   ${compo_uid}    ${resp.json()['family_history']['_uid']}
    @{compo_uid_splitted}   Split String    ${compo_uid}[0]    ::
    Set Test Variable       ${compo_id}     ${compo_uid_splitted}[0]
    Should Be Equal     ${compo_uid_splitted}[1]    ${system_id_with_tenant}
    Should Be Equal     ${compo_uid_splitted}[2]    4
    Dictionary Should Contain Item      ${resp.headers}     ETag    "${compo_uid}[0]"
    Dictionary Should Contain Item      ${resp.headers}     EHRBase-Template-ID     ${template_id}

15. Delete Compo V1 EHRSCAPE Migrated
    Commit Composition OpenEHR       composition=family_history__.json   format=FLAT
    Should Be Equal     ${resp.status_code}     ${201}
    Set Test Variable   ${compo_uid}    ${resp.json()['family_history/_uid']}
    Delete Composition OpenEHR
    Should Be Equal     ${resp.status_code}     ${204}

16. Delete Compo V2 EHRSCAPE Migrated
    #Create compo
    Commit Composition OpenEHR      composition=family_history__.xml   format=XML
    Should Be Equal     ${resp.status_code}     ${201}
    ${xresp}        Parse Xml       ${resp.text}
    ${compo_uid}    Get Element Text        ${xresp}    uid/value
    Set Test Variable       ${compo_uid}    ${compo_uid}
    @{compo_uid_splitted}   Split String    ${compo_uid}    ::
    Set Test Variable       ${compo_id}     ${compo_uid_splitted}[0]
    ##Update compo
    Update Composition OpenEHR       composition=family_history.v2__.xml   format=XML
    Should Be Equal     ${resp.status_code}     ${200}
    ${xresp}        Parse Xml       ${resp.text}
    ${compo_uid}    Get Element Text        ${xresp}    uid/value
    Set Test Variable       ${compo_uid}    ${compo_uid}
    #Delete compo using ${compo_uid} (version 2)
    Delete Composition OpenEHR
    Should Be Equal     ${resp.status_code}     ${204}

17. Get Template Example FLAT EHRSCAPE Migrated
    Get Template Example OpenEHR    format=FLAT
    Should Be Equal     ${resp.status_code}     ${200}
    Should Be Equal     ${resp.json()['family_history/composer|name']}      Max Mustermann

18. Get Template Example JSON EHRSCAPE Migrated
    Get Template Example OpenEHR    format=JSON
    Should Be Equal     ${resp.status_code}     ${200}
    Should Be Equal     ${resp.json()['name']['value']}      Family history

19. Get Template Example XML EHRSCAPE Migrated
    Get Template Example OpenEHR    format=XML
    Should Be Equal     ${resp.status_code}     ${200}
    ${xresp}        Parse Xml       ${resp.text}
    ${compo_name_value}    Get Element Text        ${xresp}    name/value
    Should Be Equal     ${compo_name_value}      Family history

20. Get Template Example STRUCTURED EHRSCAPE Migrated
    Get Template Example OpenEHR    format=STRUCTURED
    Should Be Equal     ${resp.status_code}     ${200}
    Should Be Equal     ${resp.json()['family_history']['composer'][0]['|name']}      Max Mustermann
    [Teardown]      (admin) delete ehr


*** Keywords ***
Precondition
	${variable_exists}      Run Keyword And Return Status
    ...     Variable Should Exist    ${MULTITENANCY_ENV_ENABLED}
    IF      '${MULTITENANCY_ENV_ENABLED}' == 'true' and '${variable_exists}' == 'True'
		Set Library Search Order    RCustom  R
		#Create Tenants Generic
	END
    Upload OPT    all_types/family_history.opt
    Extract Template Id From OPT File
    create EHR
    Create Session      ${SUT}    ${BASEURL}    debug=2
    ...     verify=True     #auth=${CREDENTIALS}

Headers Checks Composition
    [Arguments]     ${compo_uid_version}=1
    Dictionary Should Contain Item      ${resp.headers}     Location   ${BASEURL}/ehr/${ehr_id}/composition/${compo_id}
    Dictionary Should Contain Item      ${resp.headers}     ETag    "${compo_id}::${system_id_with_tenant}::${compo_uid_version}"
    Dictionary Should Contain Item      ${resp.headers}     EHRBase-Template-ID     ${template_id}

Commit Composition OpenEHR
    [Documentation]     Commit Composition using OpenEHR endpoint. Previously EHRSCAPE endpoint was used.
    ...                 DEPENDENCY: `Precondition` keyword as there is Upload OPT, Create EHR and Create Session
    [Arguments]     ${composition}      ${format}=FLAT
    Set Params And Headers For API Call    format=${format}    composition=${composition}
    ${resp}     POST On Session     ${SUT}      /ehr/${ehr_id}/composition      expected_status=anything
    ...     data=${file}    params=${params}    headers=${headers}
    Set Test Variable   ${resp}     ${resp}

Update Composition OpenEHR
    [Documentation]     Update Composition using OpenEHR endpoint. Previously EHRSCAPE endpoint was used.
    ...             \*{compo_uid}\* and \*{compo_id}\* are set as suite vars in test `1. Create Compo EHRSCAPE Migrated - FLAT`
    [Arguments]     ${composition}      ${format}=FLAT
    Set Params And Headers For API Call    format=${format}    composition=${composition}
    Set To Dictionary       ${headers}    If-Match=${compo_uid}
    ${resp}     PUT On Session      ${SUT}      /ehr/${ehr_id}/composition/${compo_id}      expected_status=anything
    ...     data=${file}    params=${params}    headers=${headers}
    Set Test Variable   ${resp}     ${resp}

Get Versioned Composition OpenEHR
    [Documentation]     Get Composition using OpenEHR endpoint. Previously EHRSCAPE endpoint was used.
    ...             \*{compo_uid}\* is set as test variable scope in previous test or as test variable in current test where current keyword is called.
    [Arguments]     ${format}=FLAT
    IF      '${format}' == 'FLAT'
        &{params}       Create Dictionary       format=FLAT
        Set Test Variable       ${headers}      ${headers_json_dict}
    ELSE IF     '${format}' == 'JSON'
        &{params}       Create Dictionary       format=JSON
        Set Test Variable       ${headers}      ${headers_json_dict}
    ELSE IF     '${format}' == 'XML'
        &{params}       Create Dictionary       format=XML
        Set Test Variable       ${headers}      ${headers_xml_dict}
    ELSE IF     '${format}' == 'STRUCTURED'
        &{params}       Create Dictionary       format=STRUCTURED
        Set Test Variable       ${headers}      ${headers_json_dict}
    END
    ${resp}     GET On Session      ${SUT}      /ehr/${ehr_id}/composition/${compo_uid}      expected_status=anything
    ...     params=${params}    headers=${headers}
    Set Test Variable   ${resp}     ${resp}

Delete Composition OpenEHR
    [Documentation]     Delete Composition using OpenEHR endpoint. Previously EHRSCAPE endpoint was used.
    ...             \*{compo_uid}\* is set as test variable scope in previous test or as test variable in current test where current keyword is called.
    &{headers}      Create Dictionary       If-Match=${compo_uid}
    ${resp}     DELETE On Session      ${SUT}      /ehr/${ehr_id}/composition/${compo_uid}      expected_status=anything
    ...     headers=${headers}
    Set Test Variable   ${resp}     ${resp}

Get Template Example OpenEHR
    [Documentation]     Get Template Example using OpenEHR endpoint. Previously EHRSCAPE endpoint was used.
    ...             \*{template_id}\* is set as suite variable scope in 'Precondition' keyword.
    [Arguments]     ${format}=FLAT
    IF      '${format}' == 'FLAT'
        &{params}       Create Dictionary       format=FLAT
        &{headers}      Create Dictionary       Accept=application/json
        Set Test Variable       ${headers}      ${headers}
    ELSE IF     '${format}' == 'JSON'
        &{params}       Create Dictionary       format=JSON
        &{headers}      Create Dictionary       Accept=application/json
        Set Test Variable       ${headers}      ${headers}
    ELSE IF     '${format}' == 'XML'
        &{params}       Create Dictionary       format=XML
        &{headers}      Create Dictionary       Accept=application/xml
        Set Test Variable       ${headers}      ${headers}
    ELSE IF     '${format}' == 'STRUCTURED'
        &{params}       Create Dictionary       format=STRUCTURED
        &{headers}      Create Dictionary       Accept=application/json
        Set Test Variable       ${headers}      ${headers}
    END
    ${resp}     GET On Session      ${SUT}      definition/template/adl1.4/${template_id}/example   expected_status=anything
    ...     params=${params}    headers=${headers}
    Set Test Variable   ${resp}     ${resp}

Set Params And Headers For API Call
    [Arguments]     ${format}       ${composition}
    IF      '${format}' == 'FLAT'
        ${file}         Get File        ${COMPO DATA SETS}/FLAT/${composition}
        &{params}       Create Dictionary       format=FLAT     templateId=${template_id}
        Set Test Variable       ${headers}      ${headers_json_dict}
    ELSE IF     '${format}' == 'FLAT_CONTENT_TYPE'
        ${file}         Get File        ${COMPO DATA SETS}/FLAT/${composition}
        &{params}       Create Dictionary       templateId=${template_id}
        Set Test Variable       ${headers}      ${headers_flat_content_type_dict}
    ELSE IF     '${format}' == 'JSON'
        ${file}         Get File        ${COMPO DATA SETS}/CANONICAL_JSON/${composition}
        &{params}       Create Dictionary       format=JSON     templateId=${template_id}
        Set Test Variable       ${headers}      ${headers_json_dict}
    ELSE IF     '${format}' == 'XML'
        ${file}         Get File        ${COMPO DATA SETS}/CANONICAL_XML/${composition}
        &{params}       Create Dictionary       templateId=${template_id}
        Set Test Variable       ${headers}      ${headers_xml_dict}
    ELSE IF     '${format}' == 'STRUCTURED'
        ${file}         Get File        ${COMPO DATA SETS}/STRUCTURED/${composition}
        &{params}       Create Dictionary       format=STRUCTURED       templateId=${template_id}
        Set Test Variable       ${headers}      ${headers_json_dict}
    ELSE IF     '${format}' == 'STRUCTURED_CONTENT_TYPE'
        ${file}         Get File        ${COMPO DATA SETS}/STRUCTURED/${composition}
        &{params}       Create Dictionary       templateId=${template_id}
        Set Test Variable       ${headers}      ${headers_structured_content_type_dict}
    END
    Set Test Variable   ${file}     ${file}
    Set Test Variable   ${params}   ${params}