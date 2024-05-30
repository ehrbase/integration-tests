*** Settings ***
Documentation   Authentication Type Tests
...             \nRun with AUTH_TYPE=OAUTH only
...             \nhttps://vitagroup-ag.atlassian.net/browse/CDR-1401

Resource        ../../_resources/keywords/composition_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot
Resource        ../../_resources/keywords/aql_query_keywords.robot
Resource        ../../_resources/keywords/aql_keywords.robot

Suite Setup     Set Library Search Order For Tests


*** Variables ***
${SUT}      TEST
&{TEMP_OAUTH_ACCESS_GRANT}   client_id=HIP-CDR-EHRbase-Service
...     grant_type=password     client_secret=bT5T4oWn3xNdBytQsl2cfpBDi1pp15Va
...     username=ehrbase-admin  password=EvenMoreSecretPassword1!


*** Test Cases ***
1. Keycloak OAuth server is online - OAUTH Normal User
    [Documentation]     Checks that Keycloak server is up and ready.
    ${loggedvars}   Log Variables
                    Create Session    keycloak    ${KEYCLOAK_URL}
    ${resp}         R.Get On Session    keycloak    /
                    Should Be Equal As Strings 	  ${resp.status_code}    200
    Should Be Equal     ${OAUTH_ACCESS_GRANT['username']}       ehrbase-user

2. cdr-core-sanity-check realm exists - OAUTH Normal User
    ${resp}         R.Get On Session    keycloak    /realms/cdr-core-sanity-check
    Status Should Be    200
    Should Be Equal     ${resp.json()["realm"]}     cdr-core-sanity-check
    Log     Token service URL: ${resp.json()["token-service"]}      console=yes

3. Test Get Token - OAUTH Normal User
    Request Access Token    ${OAUTH_ACCESS_GRANT}
    Status Should Be    200

4. Upload Template - OAUTH Normal User Creds
    &{authorization}        Create Dictionary
    ...     Authorization=Bearer ${password_access_token}
    Set Suite Variable      ${authorization}    ${authorization}
    Upload OPT      nested/nested.opt
    @{accepted_template_status_codes}    Create List     ${201}     ${204}     ${409}
    List Should Contain Value   ${accepted_template_status_codes}   ${response_code}

5. Create EHR - OAUTH Normal User Creds
    prepare new request session    JSON    Prefer=return=representation
    create new EHR with ehr_status  ${VALID EHR DATA SETS}/000_ehr_status_with_other_details.json
    Should Be Equal     ${resp.status_code}     ${201}
    Log     ${ehr_id}

6. Create Composition - OAUTH Normal User Creds
    prepare new request session    JSON    Prefer=return=representation
    commit composition   format=CANONICAL_JSON
    ...                  composition=nested.en.v1__full_without_links.json
    Should Be Equal     ${response.status_code}     ${201}
    check the successful result of commit composition
    @{compo_uid_splitted}   Split String    ${composition_uid}      ::
                            Set Suite Variable      ${compo_id}     ${compo_uid_splitted}[0]

7. Store Query - OAUTH Normal User Creds
    ${query}       Catenate
    ...     SELECT c/uid/value AS COMPOSITION_UID_VALUE
    ...     FROM EHR e
    ...     CONTAINS COMPOSITION c
    ...     WHERE e/ehr_id/value = '${ehr_id}'
    Set Suite Variable      ${initial_query}    ${query}
    ${resp_qualified_query_name_version}     PUT /definition/query/{qualified_query_name}/{version}
    ...     query_to_store=${query}     format=text
    Set Suite Variable     ${resp_qualified_query_name_version}     ${resp_qualified_query_name_version}

8. GET Stored Query - OAUTH Normal User Creds
    ${resp_query}       GET /definition/query/{qualified_query_name} / including {version}
    ...     qualif_name=${resp_qualified_query_name_version}
    Should Be Equal As Strings      ${resp['q']}        ${initial_query}

9. Execute Stored Query (POST) - OAUTH Normal User Creds
    ${resp_query}       POST /query/{qualified_query_name}/{version}
    ...     qualif_name=${resp_qualified_query_name_version}
    Should Be Equal As Strings      ${resp_query['q']}  ${initial_query}

10. Execute Ad-Hoc Query - OAUTH Normal User Creds
    Set Test Variable       ${test_data}    {"q":"${initial_query}"}
    Send Ad Hoc Request     aql_body=${test_data}

11. Admin Delete Composition - OAUTH Normal User Creds
    Set Test Variable   ${versioned_object_uid}     ${compo_id}
    ${err_msg}  Run Keyword And Expect Error    *
    ...     (admin) delete composition
    Should Contain      ${err_msg}      Expected status: 403 != 204

12. Admin Delete Stored Query - OAUTH Normal User Creds
    ${err_msg}  Run Keyword And Expect Error    *
    ...     (admin) delete stored query     ${resp_qualified_query_name_version}
    Should Contain      ${err_msg}      Expected status: 403 != 200
    &{OAUTH_ACCESS_GRANT}   Create Dictionary   client_id=HIP-CDR-EHRbase-Service
    ...     grant_type=password     client_secret=bT5T4oWn3xNdBytQsl2cfpBDi1pp15Va
    ...     username=ehrbase-admin  password=EvenMoreSecretPassword1!
    Request Access Token    ${TEMP_OAUTH_ACCESS_GRANT}
    Status Should Be    200
    &{authorization}        Create Dictionary
    ...     Authorization=Bearer ${password_access_token}
    Set Suite Variable   ${authorization}    ${authorization}
    [Teardown]      (admin) delete ehr


*** Keywords ***
Request Access Token
    [Arguments]         ${grant}
                        Create Session    keycloak   ${KEYCLOAK_URL}   verify=${False}    debug=3
    &{headers}=         Create Dictionary    Content-Type=application/x-www-form-urlencoded
    ${resp}=            R.POST On Session    keycloak   /realms/cdr-core-sanity-check/protocol/openid-connect/token
                        ...     expected_status=anything
                        ...     data=${grant}   headers=${headers}
                        Set Test Variable       ${resp}     ${resp}
                        dictionary should contain key       ${resp.json()}      access_token
                        Set Suite Variable      ${password_access_token}    ${resp.json()['access_token']}
