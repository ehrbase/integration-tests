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

1.a Create Compo FLAT With Uid
    [Documentation]     Covers https://vitagroup-ag.atlassian.net/browse/CDR-1512
    Commit Composition OpenEHR
    ...     composition=family_history__with_uid.json   format=FLAT     with_compo_uid=true
    Should Be Equal     ${resp.status_code}     ${201}
    Set Test Variable   ${compo_uid}        ${resp.json()['family_history/_uid']}
    Should Be Equal     ${generated_compo_uid}      ${compo_uid}

2. Create Compo JSON EHRSCAPE Migrated
    Commit Composition OpenEHR      composition=family_history__.json   format=JSON
    Should Be Equal     ${resp.status_code}     ${201}
    Set Test Variable       ${compo_uid}    ${resp.json()['uid']['value']}
    @{compo_uid_splitted}   Split String    ${compo_uid}    ::
    Set Test Variable       ${compo_id}     ${compo_uid_splitted}[0]
    Should Be Equal     ${compo_uid_splitted}[1]    ${system_id_with_tenant}
    Should Be Equal     ${compo_uid_splitted}[2]    1
    Headers Checks Composition

2.a Create Compo JSON With Uid
    [Documentation]     Covers https://vitagroup-ag.atlassian.net/browse/CDR-1512
    Commit Composition OpenEHR
    ...     composition=family_history__with_uid.json   format=JSON     with_compo_uid=true
    Should Be Equal     ${resp.status_code}     ${201}
    Set Test Variable   ${compo_uid}    ${resp.json()['uid']['value']}
    Should Be Equal     ${generated_compo_uid}      ${compo_uid}

3. Create Compo XML EHRSCAPE Migrated
    Commit Composition OpenEHR      composition=family_history__.xml   format=XML
    Should Be Equal     ${resp.status_code}     ${201}
    ${xresp}        Parse Xml       ${resp.text}
    ${compo_uid}    Get Element Text        ${xresp}    uid/value
    @{compo_uid_splitted}   Split String    ${compo_uid}    ::
    Set Test Variable       ${compo_id}     ${compo_uid_splitted}[0]
    Headers Checks Composition

3.a Create Compo XML With Uid
    [Documentation]     Covers https://vitagroup-ag.atlassian.net/browse/CDR-1512
    Commit Composition OpenEHR
    ...     composition=family_history__with_uid.xml   format=XML     with_compo_uid=true
    Should Be Equal     ${resp.status_code}     ${201}
    ${xresp}        Parse Xml       ${resp.text}
    ${compo_uid}    Get Element Text        ${xresp}    uid/value
    Should Be Equal     ${generated_compo_uid}      ${compo_uid}

4. Create Compo STRUCTURED EHRSCAPE Migrated
    Commit Composition OpenEHR      composition=family_history__.json   format=STRUCTURED
    Should Be Equal     ${resp.status_code}     ${201}
    Set Test Variable       ${compo_uid}    ${resp.json()['family_history']['_uid']}
    @{compo_uid_splitted}   Split String    ${compo_uid}[0]    ::
    Set Test Variable       ${compo_id}     ${compo_uid_splitted}[0]
    Should Be Equal     ${compo_uid_splitted}[1]    ${system_id_with_tenant}
    Should Be Equal     ${compo_uid_splitted}[2]    1
    Headers Checks Composition

4.a Create Compo STRUCTURED With Uid
    [Documentation]     Covers https://vitagroup-ag.atlassian.net/browse/CDR-1512
    Commit Composition OpenEHR
    ...     composition=family_history__with_uid.json   format=STRUCTURED     with_compo_uid=true
    Should Be Equal     ${resp.status_code}     ${201}
    Set Test Variable   ${compo_uid}    ${resp.json()['family_history']['_uid'][0]}
    Should Be Equal     ${generated_compo_uid}      ${compo_uid}

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
    [Teardown]      Run Keywords    (admin) delete ehr      AND     (admin) delete all OPTs


21. Check Media File Content Data Value After Commit And Get Composition (FLAT)
    [Documentation]     *Checks the media_file/content|data value to be the same as in Committed Composition.*
    ...                 \nmedia_file/content|data value is checked in 2 places:
    ...                 - 1. After Commit Composition (from returned composition)
    ...                 - 2. After Get Composition (FLAT)
    ...                 \n In both cases, value from \*{initial_content_data}* should be equal with value stored in \*{content_data}*.
    ...                 Covers: CDR-1466
    [Setup]     Precondition    template_file=all_types/EHRN-ABDM-OPConsultRecord.v2.0.opt
    Commit Composition OpenEHR       composition=consult_record__.json   format=FLAT
    Should Be Equal     ${resp.status_code}     ${201}
    ${file_content_json}    evaluate    json.loads('''${file}''')    json
    Set Test Variable   ${initial_content_data}     ${file_content_json['opconsultation/document_attachment/media_file/content|data']}
    Set Test Variable   ${compo_uid}    ${resp.json()['opconsultation/_uid']}
    ${content_data}     Set Variable    ${resp.json()['opconsultation/document_attachment/media_file/content|data']}
    Should Be Equal     ${initial_content_data}     ${content_data}     {initial_content_data} value != {content_data}
    #### Get Composition (in FLAT) and compare {initial_content_data} with {content_data} value returned after Get Compo.
    Get Versioned Composition OpenEHR
    Should Be Equal     ${resp.status_code}     ${200}
    ${content_data}     Set Variable    ${resp.json()['opconsultation/document_attachment/media_file/content|data']}
    Should Be Equal     ${initial_content_data}     ${content_data}     {initial_content_data} value != {content_data}

22. Check Media File Content Data Value After Commit And Get Composition (JSON)
    [Documentation]     *Checks the media_file/content|data value to be the same as in Committed Composition.*
    ...                 \nmedia_file/content|data value is checked in 2 places:
    ...                 - 1. After Commit Composition (from returned composition)
    ...                 - 2. After Get Composition (JSON)
    ...                 \n In both cases, value from \*{initial_content_data}* should be equal with value stored in \*{content_data}*.
    ...                 Covers: CDR-1466
    Commit Composition OpenEHR       composition=consult_record__.json   format=JSON
    Should Be Equal     ${resp.status_code}     ${201}
    Set Test Variable   ${compo_uid}    ${resp.json()['uid']['value']}
    ${file_content_json}    evaluate    json.loads('''${file}''')    json
    ${initial_content_data}      Get Value From Json     ${file_content_json}
    ...     $..content..data..items[?(@._type == 'CLUSTER')]..items[?(@._type == 'ELEMENT')].value.data
    Set Suite Variable  ${tmp_initial_content_data}     ${initial_content_data}
    ${content_data}     Get Value From Json    ${resp.json()}
    ...     $..content..data..items[?(@._type == 'CLUSTER')]..items[?(@._type == 'ELEMENT')].value.data
    Should Be Equal     ${initial_content_data[0]}     ${content_data[0]}     {initial_content_data} value != {content_data}
    #### Get Composition (in JSON) and compare {initial_content_data} with {content_data} value returned after Get Compo.
    Get Versioned Composition OpenEHR   format=JSON
    Should Be Equal     ${resp.status_code}     ${200}
    ${content_data}      Get Value From Json    ${resp.json()}
    ...     $..content..data..items[?(@._type == 'CLUSTER')]..items[?(@._type == 'ELEMENT')].value.data
    Should Be Equal     ${initial_content_data[0]}     ${content_data[0]}     {initial_content_data} value != {content_data}

23. Check Media File Content Data Value After Commit And Get Composition (XML)
    [Documentation]     *Checks the media_file/content|data value to be the same as in Committed Composition.*
    ...                 \nmedia_file/content|data value is checked in 2 places:
    ...                 - 1. After Commit Composition (from returned composition)
    ...                 - 2. After Get Composition (XML)
    ...                 \n In both cases, value from \*{initial_content_data}* should be equal with value stored in \*{content_data}*.
    ...                 Covers: CDR-1466
    Commit Composition OpenEHR       composition=consult_record__.xml   format=XML
    Should Be Equal     ${resp.status_code}     ${201}
    ${xresp}            Parse Xml       ${resp.text}
    ${compo_uid}        Get Element Text        ${xresp}    uid/value
    Set Test Variable   ${compo_uid}    ${compo_uid}
    ${content_data}     Get Element Text        ${xresp}    content/data/items[3]/items[1]/value/data
    Should Be Equal     ${tmp_initial_content_data[0]}     ${content_data}     {initial_content_data} value != {content_data}
    #### Get Composition (in XML) and compare {initial_content_data} with {content_data} value returned after Get Compo.
    Get Versioned Composition OpenEHR   format=XML
    Should Be Equal     ${resp.status_code}     ${200}
    ${xresp}            Parse Xml       ${resp.text}
    ${content_data}     Get Element Text        ${xresp}    content/data/items[3]/items[1]/value/data
    Should Be Equal     ${tmp_initial_content_data[0]}     ${content_data}     {initial_content_data} value != {content_data}

24. Check Media File Content Data Value After Commit And Get Composition (STRUCTURED)
    [Documentation]     *Checks the media_file/content|data value to be the same as in Committed Composition.*
    ...                 \nmedia_file/content|data value is checked in 2 places:
    ...                 - 1. After Commit Composition (from returned composition)
    ...                 - 2. After Get Composition (STRUCTURED)
    ...                 \n In both cases, value from \*{initial_content_data}* should be equal with value stored in \*{content_data}*.
    ...                 Covers: CDR-1466
    Commit Composition OpenEHR       composition=consult_record__.json   format=STRUCTURED
    Should Be Equal     ${resp.status_code}     ${201}
    Set Test Variable   ${compo_uid}    ${resp.json()['opconsultation']['_uid'][0]}
    ${file_content_json}    evaluate    json.loads('''${file}''')    json
    ${initial_content_data}      Get Value From Json     ${file_content_json}
    ...     $.opconsultation.document_attachment..media_file..content.."|data"
    ${content_data}      Get Value From Json    ${resp.json()}
    ...     $.opconsultation.document_attachment..media_file..content.."|data"
    Should Be Equal     ${initial_content_data[0]}     ${content_data[0]}     {initial_content_data} value != {content_data}
    #### Get Composition (in STRUCTURED) and compare {initial_content_data} with {content_data} value returned after Get Compo.
    Get Versioned Composition OpenEHR   format=STRUCTURED
    Should Be Equal     ${resp.status_code}     ${200}
    ${content_data}      Get Value From Json    ${resp.json()}
    ...     $.opconsultation.document_attachment..media_file..content.."|data"
    Should Be Equal     ${initial_content_data[0]}     ${content_data[0]}     {initial_content_data} value != {content_data}

25. Check Media File Content Data Value After Commit Compo (FLAT) And Get Compo (JSON)
    [Documentation]     *Checks the media_file/content|data value to be the same as in Committed Composition.*
    ...                 \nmedia_file/content|data value is checked in 2 places:
    ...                 - 1. After Commit Composition FLAT (from returned composition)
    ...                 - 2. After Get Composition (JSON)
    ...                 \n In both cases, value from \*{initial_content_data}* should be equal with value stored in \*{content_data}*.
    ...                 Covers: CDR-1466
    #[Setup]     Precondition    template_file=all_types/EHRN-ABDM-OPConsultRecord.v2.0.opt
    Commit Composition OpenEHR       composition=consult_record__.json   format=FLAT
    Should Be Equal     ${resp.status_code}     ${201}
    ${file_content_json}    evaluate    json.loads('''${file}''')    json
    Set Test Variable   ${initial_content_data}     ${file_content_json['opconsultation/document_attachment/media_file/content|data']}
    Set Test Variable   ${compo_uid}    ${resp.json()['opconsultation/_uid']}
    ${content_data}     Set Variable    ${resp.json()['opconsultation/document_attachment/media_file/content|data']}
    Should Be Equal     ${initial_content_data}     ${content_data}     {initial_content_data} value != {content_data}
    #### Get Composition (in JSON) and compare {initial_content_data} with {content_data} value returned after Get Compo.
    Get Versioned Composition OpenEHR   format=JSON
    Should Be Equal     ${resp.status_code}     ${200}
    ${content_data}      Get Value From Json    ${resp.json()}
    ...     $..content..data..items[?(@._type == 'CLUSTER')]..items[?(@._type == 'ELEMENT')].value.data
    Should Be Equal     ${initial_content_data}     ${content_data[0]}     {initial_content_data} value != {content_data}

26. Check Media File Content Data Value After Commit Compo (FLAT) And Get Compo (XML)
    [Documentation]     *Checks the media_file/content|data value to be the same as in Committed Composition.*
    ...                 \nmedia_file/content|data value is checked in 2 places:
    ...                 - 1. After Commit Composition FLAT (from returned composition)
    ...                 - 2. After Get Composition (XML)
    ...                 \n In both cases, value from \*{initial_content_data}* should be equal with value stored in \*{content_data}*.
    ...                 Covers: CDR-1466
    #[Setup]     Precondition    template_file=all_types/EHRN-ABDM-OPConsultRecord.v2.0.opt
    Commit Composition OpenEHR       composition=consult_record__.json   format=FLAT
    Should Be Equal     ${resp.status_code}     ${201}
    ${file_content_json}    evaluate    json.loads('''${file}''')    json
    Set Test Variable   ${initial_content_data}     ${file_content_json['opconsultation/document_attachment/media_file/content|data']}
    Set Test Variable   ${compo_uid}    ${resp.json()['opconsultation/_uid']}
    ${content_data}     Set Variable    ${resp.json()['opconsultation/document_attachment/media_file/content|data']}
    Should Be Equal     ${initial_content_data}     ${content_data}     {initial_content_data} value != {content_data}
    #### Get Composition (in XML) and compare {initial_content_data} with {content_data} value returned after Get Compo.
    Get Versioned Composition OpenEHR   format=XML
    Should Be Equal     ${resp.status_code}     ${200}
    ${xresp}            Parse Xml       ${resp.text}
    ${content_data}     Get Element Text        ${xresp}    content/data/items[3]/items[1]/value/data
    Should Be Equal     ${initial_content_data}     ${content_data}     {initial_content_data} value != {content_data}

27. Check Media File Content Data Value After Commit Compo (FLAT) And Get Compo (STRUCTURED)
    [Documentation]     *Checks the media_file/content|data value to be the same as in Committed Composition.*
    ...                 \nmedia_file/content|data value is checked in 2 places:
    ...                 - 1. After Commit Composition FLAT (from returned composition)
    ...                 - 2. After Get Composition (STRUCTURED)
    ...                 \n In both cases, value from \*{initial_content_data}* should be equal with value stored in \*{content_data}*.
    ...                 Covers: CDR-1466
    #[Setup]     Precondition    template_file=all_types/EHRN-ABDM-OPConsultRecord.v2.0.opt
    Commit Composition OpenEHR       composition=consult_record__.json   format=FLAT
    Should Be Equal     ${resp.status_code}     ${201}
    ${file_content_json}    evaluate    json.loads('''${file}''')    json
    Set Test Variable   ${initial_content_data}     ${file_content_json['opconsultation/document_attachment/media_file/content|data']}
    Set Test Variable   ${compo_uid}    ${resp.json()['opconsultation/_uid']}
    ${content_data}     Set Variable    ${resp.json()['opconsultation/document_attachment/media_file/content|data']}
    Should Be Equal     ${initial_content_data}     ${content_data}     {initial_content_data} value != {content_data}
    #### Get Composition (in STRUCTURED) and compare {initial_content_data} with {content_data} value returned after Get Compo.
    Get Versioned Composition OpenEHR   format=STRUCTURED
    Should Be Equal     ${resp.status_code}     ${200}
    ${content_data}      Get Value From Json    ${resp.json()}
    ...     $.opconsultation.document_attachment..media_file..content.."|data"
    Should Be Equal     ${tmp_initial_content_data[0]}      ${content_data[0]}      {initial_content_data} value != {content_data}

28. Check Media File Content Data Value After Commit Compo (XML) And Get Compo (STRUCTURED)
    [Documentation]     *Checks the media_file/content|data value to be the same as in Committed Composition.*
    ...                 \nmedia_file/content|data value is checked in 2 places:
    ...                 - 1. After Commit Composition XML (from returned composition)
    ...                 - 2. After Get Composition (STRUCTURED)
    ...                 \n In both cases, value from \*{initial_content_data}* should be equal with value stored in \*{content_data}*.
    ...                 Covers: CDR-1466
    Commit Composition OpenEHR       composition=consult_record__.xml   format=XML
    Should Be Equal     ${resp.status_code}     ${201}
    ${xresp}            Parse Xml       ${resp.text}
    ${compo_uid}        Get Element Text        ${xresp}    uid/value
    Set Test Variable   ${compo_uid}    ${compo_uid}
    ${content_data}     Get Element Text        ${xresp}    content/data/items[3]/items[1]/value/data
    Should Be Equal     ${tmp_initial_content_data[0]}     ${content_data}     {initial_content_data} value != {content_data}
    #### Get Composition (in STRUCTURED) and compare {initial_content_data} with {content_data} value returned after Get Compo.
    Get Versioned Composition OpenEHR   format=STRUCTURED
    Should Be Equal     ${resp.status_code}     ${200}
    ${content_data}      Get Value From Json    ${resp.json()}
    ...     $.opconsultation.document_attachment..media_file..content.."|data"
    Should Be Equal     ${tmp_initial_content_data[0]}      ${content_data[0]}      {initial_content_data} value != {content_data}

29. Check Media File Content Data Value After Commit Compo (XML) And Get Compo (JSON)
    [Documentation]     *Checks the media_file/content|data value to be the same as in Committed Composition.*
    ...                 \nmedia_file/content|data value is checked in 2 places:
    ...                 - 1. After Commit Composition XML (from returned composition)
    ...                 - 2. After Get Composition (JSON)
    ...                 \n In both cases, value from \*{initial_content_data}* should be equal with value stored in \*{content_data}*.
    ...                 Covers: CDR-1466
    Commit Composition OpenEHR       composition=consult_record__.xml   format=XML
    Should Be Equal     ${resp.status_code}     ${201}
    ${xresp}            Parse Xml       ${resp.text}
    ${compo_uid}        Get Element Text        ${xresp}    uid/value
    Set Test Variable   ${compo_uid}    ${compo_uid}
    ${content_data}     Get Element Text        ${xresp}    content/data/items[3]/items[1]/value/data
    Should Be Equal     ${tmp_initial_content_data[0]}     ${content_data}     {initial_content_data} value != {content_data}
    #### Get Composition (in JSON) and compare {initial_content_data} with {content_data} value returned after Get Compo.
    Get Versioned Composition OpenEHR   format=JSON
    Should Be Equal     ${resp.status_code}     ${200}
    ${content_data}      Get Value From Json    ${resp.json()}
    ...     $..content..data..items[?(@._type == 'CLUSTER')]..items[?(@._type == 'ELEMENT')].value.data
    Should Be Equal     ${tmp_initial_content_data[0]}     ${content_data[0]}       {initial_content_data} value != {content_data}

30. Check Media File Content Data Value After Commit Compo (XML) And Get Compo (FLAT)
    [Documentation]     *Checks the media_file/content|data value to be the same as in Committed Composition.*
    ...                 \nmedia_file/content|data value is checked in 2 places:
    ...                 - 1. After Commit Composition XML (from returned composition)
    ...                 - 2. After Get Composition (FLAT)
    ...                 \n In both cases, value from \*{initial_content_data}* should be equal with value stored in \*{content_data}*.
    ...                 Covers: CDR-1466
    Commit Composition OpenEHR       composition=consult_record__.xml   format=XML
    Should Be Equal     ${resp.status_code}     ${201}
    ${xresp}            Parse Xml       ${resp.text}
    ${compo_uid}        Get Element Text        ${xresp}    uid/value
    Set Test Variable   ${compo_uid}    ${compo_uid}
    ${content_data}     Get Element Text        ${xresp}    content/data/items[3]/items[1]/value/data
    Should Be Equal     ${tmp_initial_content_data[0]}     ${content_data}     {initial_content_data} value != {content_data}
    #### Get Composition (in FLAT) and compare {initial_content_data} with {content_data} value returned after Get Compo.
    Get Versioned Composition OpenEHR
    Should Be Equal     ${resp.status_code}     ${200}
    ${content_data}     Set Variable    ${resp.json()['opconsultation/document_attachment/media_file/content|data']}
    Should Be Equal     ${tmp_initial_content_data[0]}      ${content_data}     {initial_content_data} value != {content_data}

31. Check Media File Content Data Value After Commit Compo (JSON) And Get Compo (XML)
    [Documentation]     *Checks the media_file/content|data value to be the same as in Committed Composition.*
    ...                 \nmedia_file/content|data value is checked in 2 places:
    ...                 - 1. After Commit Composition JSON (from returned composition)
    ...                 - 2. After Get Composition (XML)
    ...                 \n In both cases, value from \*{initial_content_data}* should be equal with value stored in \*{content_data}*.
    ...                 Covers: CDR-1466
    Commit Composition OpenEHR       composition=consult_record__.json   format=JSON
    Should Be Equal     ${resp.status_code}     ${201}
    Set Test Variable   ${compo_uid}    ${resp.json()['uid']['value']}
    ${file_content_json}    evaluate    json.loads('''${file}''')    json
    ${initial_content_data}      Get Value From Json     ${file_content_json}
    ...     $..content..data..items[?(@._type == 'CLUSTER')]..items[?(@._type == 'ELEMENT')].value.data
    Set Suite Variable  ${tmp_initial_content_data}     ${initial_content_data}
    ${content_data}     Get Value From Json    ${resp.json()}
    ...     $..content..data..items[?(@._type == 'CLUSTER')]..items[?(@._type == 'ELEMENT')].value.data
    Should Be Equal     ${initial_content_data[0]}     ${content_data[0]}     {initial_content_data} value != {content_data}
    #### Get Composition (in XML) and compare {initial_content_data} with {content_data} value returned after Get Compo.
    Get Versioned Composition OpenEHR   format=XML
    Should Be Equal     ${resp.status_code}     ${200}
    ${xresp}            Parse Xml       ${resp.text}
    ${content_data}     Get Element Text        ${xresp}    content/data/items[3]/items[1]/value/data
    Should Be Equal     ${initial_content_data[0]}     ${content_data}     {initial_content_data} value != {content_data}

32. Check Media File Content Data Value After Commit Compo (JSON) And Get Compo (STRUCTURED)
    [Documentation]     *Checks the media_file/content|data value to be the same as in Committed Composition.*
    ...                 \nmedia_file/content|data value is checked in 2 places:
    ...                 - 1. After Commit Composition JSON (from returned composition)
    ...                 - 2. After Get Composition (STRUCTURED)
    ...                 \n In both cases, value from \*{initial_content_data}* should be equal with value stored in \*{content_data}*.
    ...                 Covers: CDR-1466
    Commit Composition OpenEHR       composition=consult_record__.json   format=JSON
    Should Be Equal     ${resp.status_code}     ${201}
    Set Test Variable   ${compo_uid}    ${resp.json()['uid']['value']}
    ${file_content_json}    evaluate    json.loads('''${file}''')    json
    ${initial_content_data}      Get Value From Json     ${file_content_json}
    ...     $..content..data..items[?(@._type == 'CLUSTER')]..items[?(@._type == 'ELEMENT')].value.data
    Set Suite Variable  ${tmp_initial_content_data}     ${initial_content_data}
    ${content_data}     Get Value From Json    ${resp.json()}
    ...     $..content..data..items[?(@._type == 'CLUSTER')]..items[?(@._type == 'ELEMENT')].value.data
    Should Be Equal     ${initial_content_data[0]}     ${content_data[0]}     {initial_content_data} value != {content_data}
    #### Get Composition (in STRUCTURED) and compare {initial_content_data} with {content_data} value returned after Get Compo.
    Get Versioned Composition OpenEHR   format=STRUCTURED
    Should Be Equal     ${resp.status_code}     ${200}
    ${content_data}      Get Value From Json    ${resp.json()}
    ...     $.opconsultation.document_attachment..media_file..content.."|data"
    Should Be Equal     ${initial_content_data[0]}      ${content_data[0]}      {initial_content_data} value != {content_data}

33. Check Media File Content Data Value After Commit Compo (JSON) And Get Compo (FLAT)
    [Documentation]     *Checks the media_file/content|data value to be the same as in Committed Composition.*
    ...                 \nmedia_file/content|data value is checked in 2 places:
    ...                 - 1. After Commit Composition JSON (from returned composition)
    ...                 - 2. After Get Composition (FLAT)
    ...                 \n In both cases, value from \*{initial_content_data}* should be equal with value stored in \*{content_data}*.
    ...                 Covers: CDR-1466
    Commit Composition OpenEHR       composition=consult_record__.json   format=JSON
    Should Be Equal     ${resp.status_code}     ${201}
    Set Test Variable   ${compo_uid}    ${resp.json()['uid']['value']}
    ${file_content_json}    evaluate    json.loads('''${file}''')    json
    ${initial_content_data}      Get Value From Json     ${file_content_json}
    ...     $..content..data..items[?(@._type == 'CLUSTER')]..items[?(@._type == 'ELEMENT')].value.data
    ${content_data}     Get Value From Json    ${resp.json()}
    ...     $..content..data..items[?(@._type == 'CLUSTER')]..items[?(@._type == 'ELEMENT')].value.data
    Should Be Equal     ${initial_content_data[0]}     ${content_data[0]}     {initial_content_data} value != {content_data}
    #### Get Composition (in FLAT) and compare {initial_content_data} with {content_data} value returned after Get Compo.
    Get Versioned Composition OpenEHR
    Should Be Equal     ${resp.status_code}     ${200}
    ${content_data}     Set Variable    ${resp.json()['opconsultation/document_attachment/media_file/content|data']}
    Should Be Equal     ${initial_content_data[0]}     ${content_data}     {initial_content_data} value != {content_data}

34. Check Media File Content Data Value After Commit Compo (STRUCTURED) And Get Compo (XML)
    [Documentation]     *Checks the media_file/content|data value to be the same as in Committed Composition.*
    ...                 \nmedia_file/content|data value is checked in 2 places:
    ...                 - 1. After Commit Composition STRUCTURED (from returned composition)
    ...                 - 2. After Get Composition (XML)
    ...                 \n In both cases, value from \*{initial_content_data}* should be equal with value stored in \*{content_data}*.
    ...                 Covers: CDR-1466
    Commit Composition OpenEHR       composition=consult_record__.json   format=STRUCTURED
    Should Be Equal     ${resp.status_code}     ${201}
    Set Test Variable   ${compo_uid}    ${resp.json()['opconsultation']['_uid'][0]}
    ${file_content_json}    evaluate    json.loads('''${file}''')    json
    ${initial_content_data}      Get Value From Json     ${file_content_json}
    ...     $.opconsultation.document_attachment..media_file..content.."|data"
    ${content_data}      Get Value From Json    ${resp.json()}
    ...     $.opconsultation.document_attachment..media_file..content.."|data"
    Should Be Equal     ${initial_content_data[0]}     ${content_data[0]}     {initial_content_data} value != {content_data}
    #### Get Composition (in XML) and compare {initial_content_data} with {content_data} value returned after Get Compo.
    Get Versioned Composition OpenEHR   format=XML
    Should Be Equal     ${resp.status_code}     ${200}
    ${xresp}            Parse Xml       ${resp.text}
    ${content_data}     Get Element Text        ${xresp}    content/data/items[3]/items[1]/value/data
    Should Be Equal     ${initial_content_data[0]}     ${content_data}     {initial_content_data} value != {content_data}

35. Check Media File Content Data Value After Commit Compo (STRUCTURED) And Get Compo (JSON)
    [Documentation]     *Checks the media_file/content|data value to be the same as in Committed Composition.*
    ...                 \nmedia_file/content|data value is checked in 2 places:
    ...                 - 1. After Commit Composition STRUCTURED (from returned composition)
    ...                 - 2. After Get Composition (JSON)
    ...                 \n In both cases, value from \*{initial_content_data}* should be equal with value stored in \*{content_data}*.
    ...                 Covers: CDR-1466
    Commit Composition OpenEHR       composition=consult_record__.json   format=STRUCTURED
    Should Be Equal     ${resp.status_code}     ${201}
    Set Test Variable   ${compo_uid}    ${resp.json()['opconsultation']['_uid'][0]}
    ${file_content_json}    evaluate    json.loads('''${file}''')    json
    ${initial_content_data}      Get Value From Json     ${file_content_json}
    ...     $.opconsultation.document_attachment..media_file..content.."|data"
    ${content_data}      Get Value From Json    ${resp.json()}
    ...     $.opconsultation.document_attachment..media_file..content.."|data"
    Should Be Equal     ${initial_content_data[0]}     ${content_data[0]}     {initial_content_data} value != {content_data}
    #### Get Composition (in JSON) and compare {initial_content_data} with {content_data} value returned after Get Compo.
    Get Versioned Composition OpenEHR   format=JSON
    Should Be Equal     ${resp.status_code}     ${200}
    ${content_data}      Get Value From Json    ${resp.json()}
    ...     $..content..data..items[?(@._type == 'CLUSTER')]..items[?(@._type == 'ELEMENT')].value.data
    Should Be Equal     ${initial_content_data[0]}     ${content_data[0]}       {initial_content_data} value != {content_data}

36. Check Media File Content Data Value After Commit Compo (STRUCTURED) And Get Compo (FLAT)
    [Documentation]     *Checks the media_file/content|data value to be the same as in Committed Composition.*
    ...                 \nmedia_file/content|data value is checked in 2 places:
    ...                 - 1. After Commit Composition STRUCTURED (from returned composition)
    ...                 - 2. After Get Composition (FLAT)
    ...                 \n In both cases, value from \*{initial_content_data}* should be equal with value stored in \*{content_data}*.
    ...                 Covers: CDR-1466
    Commit Composition OpenEHR       composition=consult_record__.json   format=STRUCTURED
    Should Be Equal     ${resp.status_code}     ${201}
    Set Test Variable   ${compo_uid}    ${resp.json()['opconsultation']['_uid'][0]}
    ${file_content_json}    evaluate    json.loads('''${file}''')    json
    ${initial_content_data}      Get Value From Json     ${file_content_json}
    ...     $.opconsultation.document_attachment..media_file..content.."|data"
    ${content_data}      Get Value From Json    ${resp.json()}
    ...     $.opconsultation.document_attachment..media_file..content.."|data"
    Should Be Equal     ${initial_content_data[0]}     ${content_data[0]}     {initial_content_data} value != {content_data}
    #### Get Composition (in FLAT) and compare {initial_content_data} with {content_data} value returned after Get Compo.
    Get Versioned Composition OpenEHR
    Should Be Equal     ${resp.status_code}     ${200}
    ${content_data}     Set Variable    ${resp.json()['opconsultation/document_attachment/media_file/content|data']}
    Should Be Equal     ${initial_content_data[0]}     ${content_data}     {initial_content_data} value != {content_data}
    [Teardown]      Run Keywords    (admin) delete ehr      AND     (admin) delete all OPTs


*** Keywords ***
Precondition
    [Arguments]     ${template_file}=all_types/family_history.opt
	Set Library Search Order For Tests
    Upload OPT    ${template_file}
    Extract Template Id From OPT File
    create EHR
    Create Session      ${SUT}    ${BASEURL}    debug=2
    ...     verify=True     #auth=${CREDENTIALS}

Headers Checks Composition
    [Arguments]     ${compo_uid_version}=1
    Dictionary Should Contain Item      ${resp.headers}     Location   ${BASEURL}/ehr/${ehr_id}/composition/${compo_id}
    Dictionary Should Contain Item      ${resp.headers}     ETag    "${compo_id}::${system_id_with_tenant}::${compo_uid_version}"
    Dictionary Should Not Contain Key   ${resp.headers}     EHRBase-Template-ID

Commit Composition OpenEHR
    [Documentation]     Commit Composition using OpenEHR endpoint. Previously EHRSCAPE endpoint was used.
    ...                 DEPENDENCY: `Precondition` keyword as there is Upload OPT, Create EHR and Create Session
    [Arguments]     ${composition}      ${format}=FLAT      ${with_compo_uid}=false
    Set Params And Headers For API Call    format=${format}    composition=${composition}
    IF      '${with_compo_uid}' != 'false'
        Set Test Variable       ${generated_compo_uid}
        ...     ${{str(uuid.uuid4())}}::${system_id_with_tenant}::1
        ${temp_file}    Replace String      ${file}     __TO_BE_REPLACED_BY_TEST__   ${generated_compo_uid}
        ${file}     Set Variable    ${temp_file}
    END
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