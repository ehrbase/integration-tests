*** Settings ***
Documentation    SYSTEM API Specific Keywords
Resource         ../suite_settings.robot


*** Variables ***
${VENDOR}   Vitagroup
${SPECS_VERSION}   1.0.3
${CONFORMANCE_PROFILE}   STANDARD


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