*** Settings ***
Documentation   API Authorization Keywords
Resource        ../suite_settings.robot
Variables       ../variables/user_creds_api_auth.yml



*** Variables ***
${BASEURL_KEYCLOAK_API_AUTH}    http://localhost:8082
${KEYCLOAK_GRANT_TYPE}      password
${KEYCLOAK_CLIENT_ID}       HIP-CDR-EHRbase-Service
${KEYCLOAK_CLIENT_SECRET}   f70f3846-91cf-422f-9fba-d759548f92f5

*** Keywords ***
Create Session For Keycloak
    Create Session    keycloak_api_auth    ${BASEURL_KEYCLOAK_API_AUTH}
    ...     verify=${False}    debug=3
    ${resp}     Get On Session    keycloak_api_auth    /auth
                    Should Be Equal As Strings 	  ${resp.status_code}    200
                    Set Test Variable   ${response}     ${resp}

Obtain Access Token From Keycloak Using User Credentials
    Create Session For Keycloak
    ${keycloak_user_username}   Set Variable    ${usercreds['username']}
    ${keycloak_user_password}   Set Variable    ${usercreds['password']}
    ${grant_string}     Catenate
    ...     grant_type=${KEYCLOAK_GRANT_TYPE}&client_id=${KEYCLOAK_CLIENT_ID}&client_secret=${KEYCLOAK_CLIENT_SECRET}
    ...     &username=${usercreds['username']}&password=${usercreds['password']}
    &{headers}      Create Dictionary       Content-Type=application/x-www-form-urlencoded
    ${resp}         POST On Session     keycloak_api_auth   auth/realms/Sacred Heart/protocol/openid-connect/token
                    ...     expected_status=anything
                    ...     data=${grant_string.replace(" ", "")}   headers=${headers}
            Should Be Equal As Strings      ${resp.status_code}     ${200}
            Set Test Variable   ${response}         ${resp}
            Set Test Variable   ${response_body}    ${resp.json()}
            Set Test Variable   ${response_access_token}    ${resp.json()['access_token']}
            Log To Console      \naccess_token: ${response_body['access_token']}
            Log To Console      \nexpires_in: ${response_body['expires_in']}
            Log To Console      \nrefresh_expires_in: ${response_body['refresh_expires_in']}
            Log To Console      \ntoken_type: ${response_body['token_type']}
            Log To Console      \nscope: ${response_body['scope']}

Set Credentials For User
    [Arguments]     ${userType}
    ${user_type}    Set Variable    ${userType}
    Set Test Variable    ${usercreds}    ${user.${user_type}}
    Log To Console    \nNext steps will be performed with credentials from user > ${userType}

#Decode JWT And Get Access Token
#    [Documentation]     Decode JWT token provided as argument and returns access_token value.
#    ...         Takes 1 argument: in_token;
#    ...         \nReturns accessToken value.
#    [Arguments]     ${in_token}
#    &{decoded_token}    decode token        ${in_token}
#                        Log To Console      \naccess_token: ${decoded_token.access_token}
#                        Log To Console      \nexpires_in: ${decoded_token.expires_in}
#                        Log To Console      \nrefresh_expires_in: ${decoded_token.refresh_expires_in}
#                        Log To Console      \ntoken_type: ${decoded_token.token_type}
#                        Log To Console      \nscope: ${decoded_token.scope}
#                        Set Test Variable   ${accessToken}     ${decoded_token.access_token}
#                        #Dictionary Should Contain Item    ${decoded_token}    typ   Bearer
#    [Return]        ${accessToken}
