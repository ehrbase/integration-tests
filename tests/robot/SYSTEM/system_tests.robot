*** Settings ***
Documentation   Test suite to check System API Options and Conformance.
...             \nCovers https://vitagroup-ag.atlassian.net/browse/CDR-2639
Resource    ${EXECDIR}/robot/_resources/suite_settings.robot
Suite Setup 		Set Library Search Order For Tests
Suite Teardown      Delete All Sessions


*** Variables ***
@{expected_endpoints}    /ehr  /definition  /query  /admin
@{expected_system_keys}  solution   solution_version   vendor   restapi_specs_version   conformance_profile   endpoints
${VENDOR}   Vitagroup
${SPECS_VERSION}   1.0.3
${CONFORMANCE_PROFILE}   STANDARD


*** Test Cases ***
Main OPTIONS System Test
    [Tags]      Positive
    OPTIONS System Request
    OPTIONS System Check Response Headers
    OPTIONS System Check Response Body
    Solution Value Is Correct
    Solution Version Is Correct
    Other Values Are Correct

OPTIONS System Test With URL /ehrbase/rest/openehr/v1/
    [Tags]      Positive
    OPTIONS System Request    url=/
    OPTIONS System Check Response Headers
    OPTIONS System Check Response Body
    Solution Value Is Correct
    Solution Version Is Correct
    Other Values Are Correct

OPTIONS System Test With Non Existing URL - Expect 404
    [Tags]      Negative
    Run Keyword And Expect Error    *
    ...     OPTIONS System Request    url=/non-existing
    Status Should Be    404
    Should Be Equal     ${resp_json['error']}   Not Found

OPTIONS System Test With Accept application/xml - Expect 406
    [Tags]      Negative
    ${h}=    Set Headers To OPTIONS System Request
             ...      Accept=application/xml
    Run Keyword And Expect Error    *
    ...     OPTIONS System Request With Custom Headers     url=/   headers=${h}
    Status Should Be    406
    Should Contain      ${resp.content}     <message>No acceptable representation</message>


*** Keywords ***
Create System API Session
    ${sessionExists}     Session Exists      ${SUT}
    IF    not ${session_exists}     Create Session    ${SUT}    ${BASEURL}    verify=True

OPTIONS System Request
    [Arguments]     ${url}=${EMPTY}
    Create System API Session
    ${resp}     OPTIONS On Session  ${SUT}      ${url}      expected_status=anything
                Set Test Variable   ${resp_headers}    ${resp.headers}
                Set Test Variable   ${resp_json}    ${resp.json()}
                Status Should Be    200     ${resp}

OPTIONS System Request With Custom Headers
    [Arguments]     ${url}=${EMPTY}     ${headers}=${None}
    Create System API Session
    ${resp}     OPTIONS On Session  ${SUT}      ${url}
                ...                 headers=${headers}      expected_status=anything
                Set Test Variable   ${resp}     ${resp}
                Set Test Variable   ${resp_headers}    ${resp.headers}
                Set Test Variable   ${resp_json}    ${resp.json()}
                Status Should Be    200     ${resp}

OPTIONS System Check Response Body
    JSON Keys Are Present
    Endpoints Are Present

JSON Keys Are Present
    FOR     ${key}   IN      @{expected_system_keys}
        Run Keyword And Continue On Failure
        ...     Dictionary Should Contain Key   ${resp_json}    ${key}
        ...     msg=Dictionary '${resp_json}' does not contain '${key}'
    END

Endpoints Are Present
    ${endpoints_arr}    Set Variable    ${resp_json['endpoints']}
    Length Should Be    ${endpoints_arr}   4
    FOR     ${el}   IN      @{expected_endpoints}
        Run Keyword And Continue On Failure
        ...     Should Contain      ${endpoints_arr}   ${el}
    END
    Should Not Contain  ${endpoints_arr}    /demographic

OPTIONS System Check Response Headers
    Dictionary Should Contain Item      ${resp_headers}     Allow    GET,POST,PUT,DELETE,OPTIONS
    Dictionary Should Contain Item      ${resp_headers}     Content-Type    application/json

Solution Value Is Correct
    ${auth}         Set Variable    ${resp_headers.get("Authorization", "")}
    ${expected}     Set Variable If    '''${auth}'''.startswith('Bearer ') and len('''${auth}''') > 7
    ...             HIP-EHRbase    EHRbase
    Dictionary Should Contain Item    ${resp_json}    solution    ${expected}

Solution Version Is Correct
    [Documentation]     - Get ehrbase_version using GET {baseUrl}/rest/status <ehrbase_version>...</ehrbase_version>
    ...                 - Compare expected value from ehrbase_version with actual value returned in solution_version
    ${temp_str}     Remove String   ${BASEURL}  /rest/openehr/v1
    ${TMP_BASEURL}  Set Variable    ${temp_str}
    Create Session      EHRBASE_STATUS_SESSION      ${TMP_BASEURL}    verify=True
    ${resp}     GET On Session      EHRBASE_STATUS_SESSION      /rest/status    expected_status=anything
                Status Should Be    200     ${resp}
                ${expected_version}  Get Element Text    ${resp.content}    ehrbase_version
    Should Be Equal     v${expected_version}     ${resp_json['solution_version']}

Other Values Are Correct
    Should Be Equal     ${resp_json['vendor']}      ${VENDOR}
    Should Be Equal     ${resp_json['restapi_specs_version']}   ${SPECS_VERSION}
    Should Be Equal     ${resp_json['conformance_profile']}     ${CONFORMANCE_PROFILE}

Set Headers To OPTIONS System Request
    [Documentation]    Builds headers for OPTIONS {base}/.
    ...                Defaults: Accept and Content-Type = application/json.
    ...                Adds Authorization from ${resp_headers} if it holds a Bearer token.
    ...                Any name=value pairs passed in are added last and override the rest.
    [Arguments]        &{extra_headers}
    &{headers}=        Create Dictionary
    ...                Accept=application/json
    ...                Content-Type=application/json

    ${source}=         Get Variable Value    \${resp_headers}    ${{ {} }}
    ${auth}=           Evaluate    $source.get("Authorization", "") if hasattr($source, "get") else ""
    IF    $auth.startswith("Bearer ") and len($auth) > 7
        Set To Dictionary    ${headers}    Authorization=${auth}
    END

    Set To Dictionary    ${headers}    &{extra_headers}
    Set Suite Variable    ${headers}
    RETURN    ${headers}