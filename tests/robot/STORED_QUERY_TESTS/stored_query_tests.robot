*** Settings ***
Documentation       STORED QUERY TEST SUITE
...                 Test suite used to check all endpoints related to Stored Query
...                 Covered methods: GET, POST, PUT, DELETE
...                 \nCovers Definition endpoints:
...                 - PUT /rest/openehr/v1/definition/query/{qualified_query_name}
...                 - GET /rest/openehr/v1/definition/query/{qualified_query_name}
...                 - GET /rest/openehr/v1/definition/query
...                 - PUT /rest/openehr/v1/definition/query/{qualified_query_name}/{version}
...                 - GET /rest/openehr/v1/definition/query/{qualified_query_name}/{version}
...                 - DELETE /rest/openehr/v1/definition/query/{qualified_query_name}/{version}
...                 \nCovers Query endpoints:
...                 - GET /rest/openehr/v1/query/{qualified_query_name}
...                 - POST /rest/openehr/v1/query/{qualified_query_name}
...                 - GET /rest/openehr/v1/query/{qualified_query_name}/{version}
...                 - POST /rest/openehr/v1/query/{qualified_query_name}/{version}

Resource            ../_resources/keywords/composition_keywords.robot
Resource            ../_resources/keywords/ehr_keywords.robot
Resource            ../_resources/keywords/aql_query_keywords.robot


#Suite Setup       Precondition

#*** Variables ***
#${COMPOSITIONS_PATH_JSON}       ${EXECDIR}/robot/_resources/test_data_sets/compositions/CANONICAL_JSON
#${COMPOSITIONS_PATH_XML}        ${EXECDIR}/robot/_resources/test_data_sets/compositions/CANONICAL_XML


*** Test Cases ***
PUT Stored Query Using Qualified Query Name
    [Documentation]     Test to check below endpoint:
    ...                 - PUT /rest/openehr/v1/definition/query/{qualified_query_name}
    ...                 Expected response status code = 200
    [Setup]     Precondition
    ${query}       Catenate
    ...     SELECT c/uid/value as COMPOSITION_UID_VALUE
    ...     FROM EHR e
    ...     CONTAINS composition c
    ...     WHERE e/ehr_id/value='${ehr_id}'
    Set Suite Variable     ${initial_query}     ${query}
    ${resp_qualified_query_name}     PUT /definition/query/{qualified_query_name}
    ...     query_to_store=${query}     format=text
    Set Suite Variable      ${resp_qualified_query_name}    ${resp_qualified_query_name}

GET Stored Query Using Qualified Query Name
    [Documentation]     Test to check below endpoint:
    ...                 - GET /rest/openehr/v1/definition/query/{qualified_query_name}
    ...                 Expected:
    ...                 - response status code = 200
    ...                 - name = ${resp_qualified_query_name} (automatically generated after test 'PUT Stored Query Using Qualified Query Name')
    ...                 - type = AQL
    ...                 - version = 1.0.0 (automatically generated after test 'PUT Stored Query Using Qualified Query Name')
    ${resp_query}       GET /definition/query/{qualified_query_name} / including {version}
    ...     qualif_name=${resp_qualified_query_name}
    ${resp_versions_arr}    Set Variable    ${resp['versions'][0]}
    Should Be Equal As Strings     ${resp_versions_arr['name']}       ${resp_qualified_query_name}
    Should Be Equal As Strings     ${resp_versions_arr['type']}       AQL
    Should Be Equal As Strings     ${resp_versions_arr['version']}    1.0.0
    Log     ${resp_versions_arr['saved']}

PUT Stored Query Using Qualified Query Name And Version
    [Documentation]     Test to check below endpoint:
    ...                 - PUT /rest/openehr/v1/definition/query/{qualified_query_name}/{version}
    ...                 Expected response status code = 200
    ${resp_qualified_query_name_version}     PUT /definition/query/{qualified_query_name}/{version}
    ...     query_to_store=${initial_query}     format=text
    Log     ${resp_qualified_query_name_version}
    Set Suite Variable      ${resp_qualified_query_name_version}        ${resp_qualified_query_name_version}

GET Stored Query Using Qualified Query Name And Version
    [Documentation]     Test to check below endpoint:
    ...                 - GET /rest/openehr/v1/definition/query/{qualified_query_name}/{version}
    ...                 Expected:
    ...                 - response status code = 200
    ...                 - q = ${initial_query}
    ...                 - name = ${resp_qualified_query_name_version} *value before /*
    ...                 - version = ${resp_qualified_query_name_version} *value after /*
    ...                 - type = AQL
    ...                 *${resp_qualified_query_name_version}* is automatically generated after test 'PUT Stored Query Using Qualified Query Name And Version'
    ${resp_query}       GET /definition/query/{qualified_query_name} / including {version}
    ...     qualif_name=${resp_qualified_query_name_version}
    Should Be Equal As Strings      ${resp['q']}        ${initial_query}
    @{splitted_query_name_version}  Split String    ${resp_qualified_query_name_version}    /
    Should Be Equal As Strings      ${resp['name']}        ${splitted_query_name_version}[0]
    Should Be Equal As Strings      ${resp['version']}     ${splitted_query_name_version}[1]
    Should Be Equal As Strings      ${resp['type']}        AQL
    Log     ${resp['saved']}

#GET All Stored Queries
#
#DELETE Stored Query Using Qualified Query Name And Version
#
#Execute - GET Stored Query Using Qualified Query Name
#
#Execute - POST Stored Query Using Qualified Query Name
#
#Execute - GET Stored Query Using Qualified Query Name And Version
#
#Execute - POST Stored Query Using Qualified Query Name And Version


*** Keywords ***
Precondition
    Upload OPT    nested/nested.opt
    Extract Template Id From OPT File
    prepare new request session   JSON      Prefer=return=representation
    Create EHR With EHR Status
    commit composition   format=CANONICAL_JSON
    ...                  composition=nested.en.v1__full_without_links.json
    check the successful result of commit composition

Create EHR With EHR Status
    [Documentation]     Create EHR with EHR_Status and other details, so it can contain correct subject object.
    create new EHR with ehr_status  ${VALID EHR DATA SETS}/000_ehr_status_with_other_details.json
                        Integer    response status    201
    ${ehr_id_obj}=      Object    response body ehr_id
    ${ehr_id_value}=    String    response body ehr_id value
                        Set Suite Variable    ${ehr_id_obj}    ${ehr_id_obj}
                        Set Suite Variable    ${ehr_id}    ${ehr_id_value}[0]