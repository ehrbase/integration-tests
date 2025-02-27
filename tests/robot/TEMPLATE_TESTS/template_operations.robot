*** Settings ***
Documentation       TEMPLATE OPERATIONS TEST SUITE
...                 \n*Covers ticket*: https://vitagroup-ag.atlassian.net/browse/CDR-1471

Resource            ../_resources/keywords/composition_keywords.robot
Resource            ../_resources/keywords/admin_keywords.robot
Suite Setup 		Set Library Search Order For Tests


*** Variables ***
${WEB TEMPLATES DATA SETS}     ${PROJECT_ROOT}${/}tests${/}robot${/}_resources${/}test_data_sets${/}valid_templates${/}expected_webtemplates


*** Test Cases ***
1. Create Template
    [Tags]      Positive
    Upload OPT      all_types/test_event.opt
    Extract Template Id From OPT File
    [Teardown]      (admin) delete OPT

2. Create Template With Content Type And Accept Headers (application/json)
    [Tags]      Negative
    prepare new request session    JSON
    ...     Prefer=return=representation
    get valid OPT file      all_types/test_event.opt
    upload OPT file
    Should Be Equal     ${response_code}    ${415}
    [Teardown]      Run Keyword And Return Status   (admin) delete OPT

3. Create Template With Content Type (application/json)
    [Tags]      Negative
    prepare new request session    no accept header
    ...     Prefer=return=representation
    upload OPT file
    Should Be Equal     ${response_code}    ${415}
    [Teardown]      Run Keyword And Return Status   (admin) delete OPT

4. Create Template With Accept (application/json)
    [Tags]      Negative
    prepare new request session    no content header
    ...     Prefer=return=representation
    upload OPT file
    Should Be Equal     ${response_code}    ${415}
    [Teardown]      Run Keyword And Return Status   (admin) delete OPT

5. Create Template With No Headers
    [Tags]      Negative
    prepare new request session    no headers
    ...     Prefer=return=representation
    upload OPT file
    Should Be Equal     ${response_code}    ${415}
    Should Contain      ${response.json()["error"]}       Unsupported Media Type
    [Teardown]      Run Keyword And Return Status   (admin) delete OPT

6. Get Template
    [Tags]      Positive
    Upload OPT      all_types/test_event.opt
    Extract Template Id From OPT File
    retrieve OPT by template_id     ${template_id}

7. Get Template With Content Type (application/json)
    [Tags]      Positive
    prepare new request session    no accept header
    ...     Prefer=return=representation
    ${resp}     GET On Session      ${SUT}    /definition/template/adl1.4/${template_id}    expected_status=anything
                ...     headers=${headers}
                Log     ${resp.text}
                Should Be Equal As Strings   ${resp.status_code}   200
    ${xml}      Parse Xml       ${resp.text}
                Set Test Variable    ${actual}    ${xml}

8. Get Template With Content Type (application/xml)
    [Tags]      Positive
    prepare new request session     no accept header xml
    ...     Prefer=return=representation
    ${resp}     GET On Session      ${SUT}    /definition/template/adl1.4/${template_id}    expected_status=anything
                ...     headers=${headers}
                Should Be Equal As Strings   ${resp.status_code}   200

9. Get Template With Accept (application/json)
    [Tags]      Positive
    prepare new request session     no content header
    ...     Prefer=return=representation
    ${resp}     GET On Session      ${SUT}    /definition/template/adl1.4/${template_id}    expected_status=anything
                ...     headers=${headers}
                Should Be Equal As Strings   ${resp.status_code}   200

10. Get Template With Accept (application/openehr.wt+json)
    [Tags]      Positive
    prepare new request session     no headers
    ...     Accept=application/openehr.wt+json
    ...     Prefer=return=representation
    ${resp}     GET On Session      ${SUT}    /definition/template/adl1.4/${template_id}    expected_status=anything
                ...     headers=${headers}
                Should Be Equal As Strings   ${resp.status_code}   200

11. Get All Templates
    [Tags]      Positive
    Set Test Variable   ${template_id_1}    ${template_id}      #template_id created in '6. Get Template'
    Upload OPT      minimal/minimal_action.opt
    Extract Template Id From OPT File
    Set Test Variable   ${template_id_2}    ${template_id}
    prepare new request session    no headers
    ...     Prefer=return=representation
    ${resp}     GET On Session      ${SUT}    /definition/template/adl1.4       expected_status=anything
                ...     headers=${headers}
                Should Be Equal As Strings   ${resp.status_code}   200
                ${len}     Get Length   ${resp.json()}
                Should Be True      ${len}>1
    Set Test Variable   ${template_id}    ${template_id_1}
    (admin) delete OPT
    Set Test Variable   ${template_id}    ${template_id_2}
    (admin) delete OPT

12. Create Second Same Template Without Compositions And Expect 409
    [Documentation]     Check that template overwrite is not possible.
    ...     Expected 409. Operational template with this template ID already exists: test_event
    ...     EHRBase started with default system.allow-template-overwrite: false
    ...     Covers bug ticket https://vitagroup-ag.atlassian.net/browse/CDR-1616
    #To remove not-ready tag when https://vitagroup-ag.atlassian.net/browse/CDR-1616 is merged
    [Tags]      Negative
    Upload OPT      all_types/test_event.opt
    Extract Template Id From OPT File
    Upload OPT      all_types/test_event.opt
    Should Be Equal As Strings      ${response_code}    409
    Should Contain      ${response.text}      Operational template with this template ID already exists: test_event
    [Teardown]      (admin) delete OPT

13. Check Corona Anamnese Template Returned In Web Template Format
    [Documentation]     Covers: https://vitagroup-ag.atlassian.net/browse/CDR-1780
    [Tags]      Positive
    Upload OPT      all_types/Corona_Anamnese.opt
    Extract Template Id From OPT File
    prepare new request session    webtemplate format
    ...     Prefer=return=representation
    ${resp}     GET On Session      ${SUT}    /definition/template/adl1.4/${template_id}
                ...     expected_status=anything
                ...     headers=${headers}
                Should Be Equal As Strings   ${resp.status_code}   200
    ${expected_result}      Set Variable    ${WEB TEMPLATES DATA SETS}/Corona_Anamnese_wt.json
    ${diff}     compare json-string with json-file
    ...     ${resp.json()}     ${expected_result}
    ...     ignore_order=${TRUE}    ignore_string_case=${TRUE}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!
    [Teardown]      (admin) delete OPT

14. Check IPS Template Returned In Web Template Format
    [Documentation]     Covers: https://vitagroup-ag.atlassian.net/browse/CDR-1780
    [Tags]      Positive
    Upload OPT      all_types/International_Patient_Summary.opt
    Extract Template Id From OPT File
    prepare new request session    webtemplate format
    ...     Prefer=return=representation
    ${resp}     GET On Session      ${SUT}    /definition/template/adl1.4/${template_id}
                ...     expected_status=anything
                ...     headers=${headers}
                Should Be Equal As Strings   ${resp.status_code}   200
    ${expected_result}      Set Variable    ${WEB TEMPLATES DATA SETS}/International_Patient_Summary_wt.json
    ${diff}     compare json-string with json-file
    ...     ${resp.json()}     ${expected_result}
    ...     ignore_order=${TRUE}    ignore_string_case=${TRUE}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!
    [Teardown]      (admin) delete OPT

15. Check GECCO Template Returned In Web Template Format
    [Documentation]     Covers: https://vitagroup-ag.atlassian.net/browse/CDR-1780
    [Tags]      Positive
    Upload OPT      all_types/GECCO_Serologischer_Befund.opt
    Extract Template Id From OPT File
    prepare new request session    webtemplate format
    ...     Prefer=return=representation
    ${resp}     GET On Session      ${SUT}    /definition/template/adl1.4/${template_id}
                ...     expected_status=anything
                ...     headers=${headers}
                Should Be Equal As Strings   ${resp.status_code}   200
    ${expected_result}      Set Variable    ${WEB TEMPLATES DATA SETS}/GECCO_Serologischer_Befund_wt.json
    ${diff}     compare json-string with json-file
    ...     ${resp.json()}     ${expected_result}
    ...     ignore_order=${TRUE}    ignore_string_case=${TRUE}
    Should Be Empty    ${diff}    msg=DIFF DETECTED!
    [Teardown]      (admin) delete OPT