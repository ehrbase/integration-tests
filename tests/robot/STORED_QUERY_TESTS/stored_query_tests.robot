*** Settings ***
Documentation       STORED QUERY TEST SUITE
...                 Test suite used to check all endpoints related to Stored Query
...                 Covered methods: GET, POST, PUT, DELETE
...                 \n*Covers Definition API endpoints https://specifications.openehr.org/releases/ITS-REST/latest/definition.html#tag/Query*:
...                 - PUT /rest/openehr/v1/definition/query/{qualified_query_name}
...                 - GET /rest/openehr/v1/definition/query/{qualified_query_name}
...                 - GET /rest/openehr/v1/definition/query
...                 - PUT /rest/openehr/v1/definition/query/{qualified_query_name}/{version}
...                 - GET /rest/openehr/v1/definition/query/{qualified_query_name}/{version}
...                 - DELETE /rest/openehr/v1/definition/query/{qualified_query_name}/{version}
...                 \n*Covers Query API endpoints https://specifications.openehr.org/releases/ITS-REST/latest/query.html*:
...                 - GET /rest/openehr/v1/query/{qualified_query_name}
...                 - POST /rest/openehr/v1/query/{qualified_query_name}
...                 - GET /rest/openehr/v1/query/{qualified_query_name}/{version}
...                 - POST /rest/openehr/v1/query/{qualified_query_name}/{version}
...                 JIRA ticket: https://vitagroup-ag.atlassian.net/browse/CDR-1068
...                 \n*Bug ticket for skipped tests with Negative tag*: https://vitagroup-ag.atlassian.net/browse/CDR-1069

Resource            ../_resources/keywords/composition_keywords.robot
Resource            ../_resources/keywords/ehr_keywords.robot
Resource            ../_resources/keywords/aql_query_keywords.robot
Resource            ../_resources/keywords/admin_keywords.robot
Suite Setup 		Set Library Search Order For Tests


*** Variables ***
${inexistent_qualif_query_name}     org.inexistient_qualif_name.abc::compo


*** Test Cases ***
Definition API - PUT Stored Query Using Qualified Query Name
    [Tags]      Positive
    [Documentation]     Test to check below endpoint:
    ...                 - PUT /rest/openehr/v1/definition/query/{qualified_query_name}
    ...                 Expected response status code = 200
    [Setup]     Precondition
    ${query}       Catenate
    ...     SELECT c/uid/value AS COMPOSITION_UID_VALUE
    ...     FROM EHR e
    ...     CONTAINS COMPOSITION c
    ...     WHERE e/ehr_id/value = '${ehr_id}'
    Set Suite Variable     ${initial_query}     ${query}
    ${resp_qualified_query_name}     PUT /definition/query/{qualified_query_name}
    ...     query_to_store=${query}     format=text
    Set Suite Variable      ${resp_qualified_query_name}    ${resp_qualified_query_name}

Definition API - PUT Stored Query Using Qualified Query Name - Invalid AQL Statement
    [Tags]      Negative
    [Documentation]     Test to check below endpoint:
    ...                 - PUT /rest/openehr/v1/definition/query/{qualified_query_name} with invalid AQL statement
    ...                 Expected response status code = 400
    ${wrong_query}       Catenate
    ...     SELECT c/uid/value AS COMPOSITION_UID_VALUE
    ...     FROM EHR e
    ...     CONTAINS COMPOSITION c
    ...     FROM EHR e
    ...     WHERE e/ehr_id/value = '${ehr_id}' WHERE e/ehr_id/value = '${ehr_id}'
    Run Keyword And Expect Error    	400 != 200
    ...     PUT /definition/query/{qualified_query_name}
    ...     query_to_store=${wrong_query}     format=text

Definition API - GET Stored Query Using Qualified Query Name
    [Tags]      Positive
    [Documentation]     Test to check below endpoint:
    ...                 - GET /rest/openehr/v1/definition/query/{qualified_query_name}
    ...                 Expected:
    ...                 - response status code = 200
    ...                 - name = ${resp_qualified_query_name} (automatically generated after test 'PUT Stored Query Using Qualified Query Name')
    ...                 - type = AQL
    ...                 - version = 1.0.0 (automatically generated after test 'PUT Stored Query Using Qualified Query Name')
    ...                 \n*DEPENDS ON TEST* 'Definition API - PUT Stored Query Using Qualified Query Name'
    ${resp_query}       GET /definition/query/{qualified_query_name} / including {version}
    ...     qualif_name=${resp_qualified_query_name}
    ${resp_versions_arr}    Set Variable    ${resp['versions'][0]}
    Should Be Equal As Strings     ${resp_versions_arr['name']}       ${resp_qualified_query_name}
    Should Be Equal As Strings     ${resp_versions_arr['type']}       AQL
    Should Be Equal As Strings     ${resp_versions_arr['version']}    1.0.0
    Log     ${resp_versions_arr['saved']}

Definition API - PUT Stored Query Using Qualified Query Name And Version
    [Tags]      Positive
    [Documentation]     Test to check below endpoint:
    ...                 - PUT /rest/openehr/v1/definition/query/{qualified_query_name}/{version}
    ...                 Expected response status code = 200
    ${resp_qualified_query_name_version}     PUT /definition/query/{qualified_query_name}/{version}
    ...     query_to_store=${initial_query}     format=text
    Log     ${resp_qualified_query_name_version}
    Set Suite Variable      ${resp_qualified_query_name_version}        ${resp_qualified_query_name_version}
    ${second_resp_qualified_query_name_version}     PUT /definition/query/{qualified_query_name}/{version}
    ...     query_to_store=${initial_query}     format=text
    Log     ${second_resp_qualified_query_name_version}
    Set Suite Variable      ${second_resp_qualified_query_name_version}
    ...     ${second_resp_qualified_query_name_version}

Definition API - GET Stored Query Using Qualified Query Name And Version
    [Tags]      Positive
    [Documentation]     Test to check below endpoint:
    ...                 - GET /rest/openehr/v1/definition/query/{qualified_query_name}/{version}
    ...                 Expected:
    ...                 - response status code = 200
    ...                 - q = ${initial_query}
    ...                 - name = ${resp_qualified_query_name_version} *value before /*
    ...                 - version = ${resp_qualified_query_name_version} *value after /*
    ...                 - type = AQL
    ...                 *${resp_qualified_query_name_version}* is automatically generated after test 'Definition API - PUT Stored Query Using Qualified Query Name And Version'
    ${resp_query}       GET /definition/query/{qualified_query_name} / including {version}
    ...     qualif_name=${resp_qualified_query_name_version}
    Should Be Equal As Strings      ${resp['q']}        ${initial_query}
    @{splitted_query_name_version}  Split String    ${resp_qualified_query_name_version}    /
    Should Be Equal As Strings      ${resp['name']}        ${splitted_query_name_version}[0]
    Should Be Equal As Strings      ${resp['version']}     ${splitted_query_name_version}[1]
    Should Be Equal As Strings      ${resp['type']}        AQL
    Log     ${resp['saved']}

Definition API - GET Stored Query Using Inexistent Qualified Query Name And Version
    [Tags]      not-ready   Negative    CDR-1069
    [Documentation]     Test to check below endpoint:
    ...                 - GET /rest/openehr/v1/definition/query/{qualified_query_name} with inexistent {qualified_query_name} and {version} values
    ...                 \n Check that 404 is returned on GET /definition/query/{qualified_query_name}/{version} for inexistent query.
    Run Keyword And Expect Error    	404 != 200
    ...     GET /definition/query/{qualified_query_name} / including {version}
    ...     qualif_name=${inexistent_qualif_query_name}/1.2.3

Definition API - GET All Stored Queries
    [Tags]      Positive
    [Documentation]     Test to check below endpoint:
    ...                 - GET /rest/openehr/v1/definition/query
    ...                 Expected:
    ...                 - response status code = 200
    ...                 - {stored_queries_count} > 1
    ${resp_query}       GET /definition/query
    ${resp_versions_arr}        Set Variable    ${resp_query['versions']}
    ${stored_queries_count}     Get Length      ${resp_versions_arr}
    Should Be True    ${stored_queries_count} > ${1}
    FOR     ${INDEX}  IN RANGE  0   ${stored_queries_count}
        Log     ${resp_versions_arr}[${INDEX}]
    END

Definition API - Non Existing Endpoint - DELETE Stored Query Using Qualified Query Name And Version
    [Tags]      not-ready   Negative    CDR-1069
    [Documentation]     Test to check below endpoint:
    ...                 - DELETE /rest/openehr/v1/definition/query/{qualified_query_name}/{version}
    ...                 Expected:
    ...                 - response status code = 200
    ...                 Check that on GET deleted stored query by {qualified_query_name}/{version}, status code is *400*
    ...                 \n Check that 404 is returned on GET /rest/openehr/v1/definition/query/{qualified_query_name}/{version} for deleted query.
    ${isPassed}     Run Keyword And Return Status
    ...     DELETE /definition/query/{qualified_query_name}/{version}
    ...     qualif_name=${resp_qualified_query_name_version}
    IF     '${isPassed}' != '${TRUE}'
        FAIL    DELETE /rest/openehr/v1/definition/query/${resp_qualified_query_name_version} failed!
    END
    Run Keyword And Expect Error    	404 != 200
    ...     GET /definition/query/{qualified_query_name} / including {version}
    ...     qualif_name=${resp_qualified_query_name_version}

Query API - GET Stored Query Using Qualified Query Name
    [Tags]      Positive
    [Documentation]     Test to check below endpoint:
    ...                 - GET /rest/openehr/v1/query/{qualified_query_name}
    ...                 Expected:
    ...                 - response status code = 200
    ...                 - q = ${initial_query} - stored in test 'PUT Stored Query Using Qualified Query Name'
    ...                 - name = ${resp_qualified_query_name}/1.0.0
    ...                 - columns[0].path = /uid/value (value from AQL statement returned in q)
    ...                 - columns[0].name = COMPOSITION_UID_VALUE (value from AQL statement returned in q)
    ...                 - rows[0][0] = ${composition_uid}
    ...                 ${resp_qualified_query_name} took from test 'PUT Stored Query Using Qualified Query Name'
    ...                 \n*DEPENDS ON TEST* 'PUT Stored Query Using Qualified Query Name'
    ${resp_query}       GET /query/{qualified_query_name}
    ...     qualif_name=${resp_qualified_query_name}
    Should Be Equal As Strings      ${resp_query['q']}        ${initial_query}
    Should Be Equal As Strings      ${resp_query['name']}     ${resp_qualified_query_name}/1.0.0
    Should Be Equal As Strings      ${resp_query['columns'][0]['path']}     c/uid/value
    Should Be Equal As Strings      ${resp_query['columns'][0]['name']}     COMPOSITION_UID_VALUE
    Should Be Equal As Strings      ${resp_query['rows'][0][0]}     ${composition_uid}

Query API - GET Stored Query Using Qualified Query Name With Ehr Id Param
    [Tags]      Positive
    [Documentation]     Test to check below endpoint:
    ...                 - GET /rest/openehr/v1/query/{qualified_query_name}?ehr_id={ehr_id}
    ...                 \nFirst, add query using PUT /definition/query/{qualified_query_name}
    ...                 Expected:
    ...                 - response status code = 200
    ...                 - q = {second_query} - stored in the same test
    ...                 - name = {qualified_query_name}/1.0.0
    ...                 - columns[0].path = /uid/value (value from AQL statement returned in q)
    ...                 - columns[0].name = COMPOSITION_UID_VALUE (value from AQL statement returned in q)
    ...                 - rows[0][0] = ${composition_uid}
    &{params}   Create Dictionary     ehr_id=${ehr_id}
    ${query2}       Catenate
    ...     SELECT c/uid/value AS COMPOSITION_UID_VALUE
    ...     FROM EHR e
    ...     CONTAINS COMPOSITION c
    Set Test Variable     ${second_query}     ${query2}
    ${temp_qualified_query_name}     PUT /definition/query/{qualified_query_name}
    ...     query_to_store=${second_query}     format=text
    ${resp_query}       GET /query/{qualified_query_name}
    ...     qualif_name=${temp_qualified_query_name}    params=${params}
    Should Be Equal As Strings      ${resp_query['q']}        ${second_query}
    Should Be Equal As Strings      ${resp_query['name']}     ${temp_qualified_query_name}/1.0.0
    Should Be Equal As Strings      ${resp_query['columns'][0]['path']}     c/uid/value
    Should Be Equal As Strings      ${resp_query['columns'][0]['name']}     COMPOSITION_UID_VALUE
    ${rows_length}      Get Length  ${resp_query['rows']}
    IF      ${rows_length} == ${1}
        Should Be Equal As Strings      ${resp_query['rows'][0][0]}     ${composition_uid}
    ELSE IF     ${rows_length} == ${0}
        Fail    Composition with uid '${composition_uid}' is not present in rows.
    END

Query API - GET Stored Query Using Inexistent Qualified Query Name
    [Tags]      not-ready   Negative    CDR-1069
    [Documentation]     Test to check below endpoint:
    ...                 - GET /rest/openehr/v1/query/{qualified_query_name} with inexistent {qualified_query_name} value
    ...                 \n Check that 404 is returned on GET /query/{qualified_query_name} for inexistent query.
    Run Keyword And Expect Error    	404 != 200
    ...     GET /query/{qualified_query_name}
    ...     qualif_name=${inexistent_qualif_query_name}

Query API - POST Stored Query Using Qualified Query Name
    [Tags]      Positive
    [Documentation]     Test to check below endpoint:
    ...                 - POST /rest/openehr/v1/query/{qualified_query_name}
    ...                 Expected:
    ...                 - response status code = 200
    ...                 - q = ${initial_query} - stored in test 'PUT Stored Query Using Qualified Query Name'
    ...                 - name = ${resp_qualified_query_name}/1.0.0
    ...                 - columns[0].path = /uid/value (value from AQL statement returned in q)
    ...                 - columns[0].name = COMPOSITION_UID_VALUE (value from AQL statement returned in q)
    ...                 - rows[0][0] = ${composition_uid}
    ...                 ${resp_qualified_query_name} took from test 'PUT Stored Query Using Qualified Query Name'
    ...                 \n*DEPENDS ON TEST* 'PUT Stored Query Using Qualified Query Name'
    ${resp_query}       POST /query/{qualified_query_name}
    ...     qualif_name=${resp_qualified_query_name}
    Should Be Equal As Strings      ${resp_query['q']}        ${initial_query}
    Should Be Equal As Strings      ${resp_query['name']}     ${resp_qualified_query_name}/1.0.0
    Should Be Equal As Strings      ${resp_query['columns'][0]['path']}     c/uid/value
    Should Be Equal As Strings      ${resp_query['columns'][0]['name']}     COMPOSITION_UID_VALUE
    Should Be Equal As Strings      ${resp_query['rows'][0][0]}     ${composition_uid}

Query API - GET Stored Query Using Qualified Query Name And Version
    [Tags]      Positive
    [Documentation]     Test to check below endpoint:
    ...                 - GET /rest/openehr/v1/query/{qualified_query_name}/{version}
    ...                 Expected:
    ...                 - response status code = 200
    ...                 - q = ${initial_query} - stored in test 'PUT Stored Query Using Qualified Query Name'
    ...                 - name = ${second_resp_qualified_query_name_version}
    ...                 - columns[0].path = /uid/value (value from AQL statement returned in q)
    ...                 - columns[0].name = COMPOSITION_UID_VALUE (value from AQL statement returned in q)
    ...                 - rows[0][0] = ${composition_uid}
    ...                 ${second_resp_qualified_query_name_version} took from test 'Definition API - PUT Stored Query Using Qualified Query Name And Version'
    ...                 \n*DEPENDS ON TESTS*:
    ...                 - 'Definition API - PUT Stored Query Using Qualified Query Name'
    ...                 - 'Definition API - PUT Stored Query Using Qualified Query Name And Version'
    ${resp_query}       GET /query/{qualified_query_name}/{version}
    ...     qualif_name=${second_resp_qualified_query_name_version}
    Should Be Equal As Strings      ${resp_query['q']}        ${initial_query}
    Should Be Equal As Strings      ${resp_query['name']}     ${second_resp_qualified_query_name_version}
    Should Be Equal As Strings      ${resp_query['columns'][0]['path']}     c/uid/value
    Should Be Equal As Strings      ${resp_query['columns'][0]['name']}     COMPOSITION_UID_VALUE
    Should Be Equal As Strings      ${resp_query['rows'][0][0]}     ${composition_uid}

Query API - GET Stored Query Using Qualified Query Name And Version With Ehr Id Param
    [Tags]      Positive
    [Documentation]     Test to check below endpoint:
    ...                 - GET /rest/openehr/v1/query/{qualified_query_name}/{version}?ehr_id={ehr_id}
    ...                 \nFirst, add query using 'PUT /definition/query/{qualified_query_name}/{version}'
    ...                 Expected:
    ...                 - response status code = 200
    ...                 - q = {third_query} - stored in current test
    ...                 - name = {qualified_query_name}/{version}
    ...                 - columns[0].path = /uid/value (value from AQL statement returned in q)
    ...                 - columns[0].name = COMPOSITION_UID_VALUE (value from AQL statement returned in q)
    ...                 - rows[0][0] = ${composition_uid}
    &{params}   Create Dictionary     ehr_id=${ehr_id}
    ${query3}       Catenate
    ...     SELECT c/uid/value AS COMPOSITION_UID_VALUE
    ...     FROM EHR e
    ...     CONTAINS COMPOSITION c
    Set Test Variable     ${third_query}     ${query3}
    ${temp_qualified_query_name_version}     PUT /definition/query/{qualified_query_name}/{version}
    ...     query_to_store=${third_query}     format=text
    ${resp_query}       GET /query/{qualified_query_name}/{version}
    ...     qualif_name=${temp_qualified_query_name_version}    params=${params}
    Should Be Equal As Strings      ${resp_query['q']}        ${third_query}
    Should Be Equal As Strings      ${resp_query['name']}     ${temp_qualified_query_name_version}
    Should Be Equal As Strings      ${resp_query['columns'][0]['path']}     c/uid/value
    Should Be Equal As Strings      ${resp_query['columns'][0]['name']}     COMPOSITION_UID_VALUE
    ${rows_length}      Get Length  ${resp_query['rows']}
    IF      ${rows_length} == ${1}
        Should Be Equal As Strings      ${resp_query['rows'][0][0]}     ${composition_uid}
    ELSE IF     ${rows_length} == ${0}
        Fail    Composition with uid '${composition_uid}' is not present in rows.
    END

Query API - POST Stored Query Using Qualified Query Name And Version
    [Tags]      Positive
    [Documentation]     Test to check below endpoint:
    ...                 - POST /rest/openehr/v1/query/{qualified_query_name}/{version}
    ...                 Expected:
    ...                 - response status code = 200
    ...                 - q = ${initial_query} - stored in test 'PUT Stored Query Using Qualified Query Name'
    ...                 - name = ${second_resp_qualified_query_name_version}
    ...                 - columns[0].path = /uid/value (value from AQL statement returned in q)
    ...                 - columns[0].name = COMPOSITION_UID_VALUE (value from AQL statement returned in q)
    ...                 - rows[0][0] = ${composition_uid}
    ...                 ${second_resp_qualified_query_name_version} took from test 'Definition API - PUT Stored Query Using Qualified Query Name And Version'
    ...                 \n*DEPENDS ON TESTS*:
    ...                 - 'Definition API - PUT Stored Query Using Qualified Query Name'
    ...                 - 'Definition API - PUT Stored Query Using Qualified Query Name And Version'
    ${resp_query}       POST /query/{qualified_query_name}/{version}
    ...     qualif_name=${second_resp_qualified_query_name_version}
    Should Be Equal As Strings      ${resp_query['q']}        ${initial_query}
    Should Be Equal As Strings      ${resp_query['name']}     ${second_resp_qualified_query_name_version}
    Should Be Equal As Strings      ${resp_query['columns'][0]['path']}     c/uid/value
    Should Be Equal As Strings      ${resp_query['columns'][0]['name']}     COMPOSITION_UID_VALUE
    Should Be Equal As Strings      ${resp_query['rows'][0][0]}     ${composition_uid}
    [Teardown]      Run Keywords    (admin) delete ehr      AND     (admin) delete all OPTs

Query API - DELETE Stored Query Using Qualified Query Name And Version
    [Tags]      Positive
    [Documentation]     Test to check below endpoint:
    ...                 - DELETE ${ADMIN_BASEURL}/query/{qualified_query_name}/{version}
    ...                 \n Check that 200 is returned
    ...                 - GET ${BASEURL}/query/{qualified_query_name}/{version}
    ...                 \n Check that 404 is returned
    ${resp_query}       DELETE /query/{qualified_query_name}/{version} ADMIN
    ...     qualif_name=${second_resp_qualified_query_name_version}
    ###get deleted stored query - bug CDR-1069
#    Run Keyword And Expect Error    	404 != 200
#    ...     GET /query/{qualified_query_name}/{version}
#    ...     qualif_name=${second_resp_qualified_query_name_version}


*** Keywords ***
Precondition
    Upload OPT    nested/nested.opt
    Extract Template Id From OPT File
    prepare new request session   JSON      Prefer=return=representation
    Create EHR With EHR Status
    commit composition   format=CANONICAL_JSON
    ...                  composition=nested.en.v1__full_without_links.json
    check the successful result of commit composition
    #${compositionUid} is set at composition_keywords.commit composition
    Set Suite Variable      ${composition_uid}      ${compositionUid}

Create EHR With EHR Status
    [Documentation]     Create EHR with EHR_Status and other details, so it can contain correct subject object.
    create new EHR with ehr_status  ${VALID EHR DATA SETS}/000_ehr_status_with_other_details.json
