*** Settings ***
Documentation   Authentication Type Tests
...             \nRun with AUTH_TYPE=BASIC only
...             \nSUT=TEST set by default to use normal user credentials for API calls.
...             \nCheck sut_config.py file for normal user credentials.
...             \nhttps://vitagroup-ag.atlassian.net/browse/CDR-1401

Resource        ../../_resources/keywords/composition_keywords.robot
Resource        ../../_resources/keywords/admin_keywords.robot
Resource        ../../_resources/keywords/aql_query_keywords.robot
Resource        ../../_resources/keywords/aql_keywords.robot

Suite Setup     Set Library Search Order For Tests


*** Variables ***
${SUT}      TEST


*** Test Cases ***
Upload Template - Normal User Creds
    Upload OPT      nested/nested.opt
    @{accepted_template_status_codes}    Create List     ${201}     ${204}     ${409}
    List Should Contain Value   ${accepted_template_status_codes}   ${response_code}

Create EHR - Normal User Creds
    prepare new request session    JSON    Prefer=return=representation
    create new EHR with ehr_status  ${VALID EHR DATA SETS}/000_ehr_status_with_other_details.json
    Should Be Equal     ${resp.status_code}     ${201}
    Log     ${ehr_id}

Create Composition - Normal User Creds
    prepare new request session    JSON    Prefer=return=representation
    commit composition   format=CANONICAL_JSON
    ...                  composition=nested.en.v1__full_without_links.json
    Should Be Equal     ${response.status_code}     ${201}
    check the successful result of commit composition
    @{compo_uid_splitted}   Split String    ${composition_uid}      ::
                            Set Suite Variable      ${compo_id}     ${compo_uid_splitted}[0]

Store Query - Normal User Creds
    ${query}       Catenate
    ...     SELECT c/uid/value AS COMPOSITION_UID_VALUE
    ...     FROM EHR e
    ...     CONTAINS COMPOSITION c
    ...     WHERE e/ehr_id/value = '${ehr_id}'
    Set Suite Variable      ${initial_query}    ${query}
    ${resp_qualified_query_name_version}     PUT /definition/query/{qualified_query_name}/{version}
    ...     query_to_store=${query}     format=text
    Set Suite Variable     ${resp_qualified_query_name_version}     ${resp_qualified_query_name_version}

GET Stored Query - Normal User Creds
    ${resp_query}       GET /definition/query/{qualified_query_name} / including {version}
    ...     qualif_name=${resp_qualified_query_name_version}
    Should Be Equal As Strings      ${resp['q']}        ${initial_query}

Execute Stored Query (POST) - Normal User Creds
    ${resp_query}       POST /query/{qualified_query_name}/{version}
    ...     qualif_name=${resp_qualified_query_name_version}
    Should Be Equal As Strings      ${resp_query['q']}  ${initial_query}

Execute Ad-Hoc Query - Normal User Creds
    Set Test Variable       ${test_data}    {"q":"${initial_query}"}
    Send Ad Hoc Request     aql_body=${test_data}

Admin Delete Composition - Normal User Creds
    Set Test Variable   ${versioned_object_uid}     ${compo_id}
    ${err_msg}  Run Keyword And Expect Error    *
    ...     (admin) delete composition
    Should Contain      ${err_msg}      Expected status: 403 != 204

Admin Delete Stored Query - Normal User Creds
    ${err_msg}  Run Keyword And Expect Error    *
    ...     (admin) delete stored query     ${resp_qualified_query_name_version}
    Should Contain      ${err_msg}      Expected status: 403 != 200
    ##Below lines are needed as with normal credentials user cannot delete ehr, only with admin creds user.
    ##teardown is deleting ehr for cleanup
    &{authorization}    Create Dictionary   Authorization=Basic ZWhyYmFzZS1hZG1pbjpFdmVuTW9yZVNlY3JldFBhc3N3b3Jk
    Set Test Variable   ${authorization}    ${authorization}
    [Teardown]      (admin) delete ehr
