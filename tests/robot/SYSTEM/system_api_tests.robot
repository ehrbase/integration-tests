*** Settings ***
Documentation   Test suite to check System API Options and Conformance.
...             \nCovers https://vitagroup-ag.atlassian.net/browse/CDR-2639
Resource    ${EXECDIR}/robot/_resources/suite_settings.robot
Resource    ${EXECDIR}/robot/_resources/keywords/system_keywords.robot
Suite Setup 		Set Library Search Order For Tests
Suite Teardown      Delete All Sessions


*** Variables ***
@{expected_endpoints}    /ehr  /definition  /query  /admin
@{expected_system_keys}  solution   solution_version   vendor   restapi_specs_version   conformance_profile   endpoints


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