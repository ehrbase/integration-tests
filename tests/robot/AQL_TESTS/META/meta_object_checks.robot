*** Settings ***
Documentation   _Robot tests to check meta JSON object from AQL response._
...         ${\n}*Covers 7 cases*:
...         - _1. POST {ehrbase_url}/ehrbase/rest/openehr/v1/query/aql_
...         - _2. GET {ehrbase_url}/ehrbase/rest/openehr/v1/query/{qualified_query_name}_
...         - _3. GET {ehrbase_url}/ehrbase/rest/openehr/v1/query/aql?q={query}_
...         - _4. GET {ehrbase_url}/ehrbase/rest/openehr/v1/query/aql?q={query} with limit and offset query params_
...         - _5. POST http://{base_url}/ehrbase/rest/openehr/v1/query/{qualified_query_name}_
...         - _6. GET http://{base_url}/ehrbase/rest/openehr/v1/query/{qualified_query_name}/{version}_
...         - _7. POST http://{base_url}/ehrbase/rest/openehr/v1/query/{qualified_query_name}/{version}_
...         ${\n}*Checks done*:
...         - meta object has the following keys (POST): _created, _executed_aql, _schema_version, _type
...         - meta object has the following keys (GET): _created, _executed_aql, _href, _schema_version, _type
...         - _created value has ISO 8601 format
...         - _type value is RESULTSET
...         - _executed_aql value is the same as value from q key (in AQL response)
...         - _href value
...         ${\n}*Postcondition:* Delete EHR using ADMIN endpoint. This is deleting compositions linked to EHR.
Resource        ../../_resources/keywords/aql_keywords.robot
Resource        ../../_resources/keywords/aql_query_keywords.robot

#Suite Setup  Skip    enable Setup 'Precondition' if AQL checks are passing !!!
#Suite Teardown  Skip    enable Teardown 'Admin Delete EHR For AQL' if AQL checks are passing !!!
Suite Setup     Precondition        #enable this keyword if AQL checks are passing !!!
Suite Teardown  Admin Delete EHR For AQL       #enable this keyword if AQL checks are passing !!!


*** Variables ***
@{expected_meta_keys_post}      _created    _executed_aql   _schema_version     _type
@{expected_meta_keys_get}       _created    _executed_aql   _href   _schema_version     _type
${query1}   SELECT o FROM SECTION [openEHR-EHR-SECTION.conformance_section.v0] CONTAINS OBSERVATION o CONTAINS CLUSTER
${query2}   SELECT o FROM SECTION CONTAINS OBSERVATION o CONTAINS CLUSTER
${query3}   SELECT o FROM SECTION [openEHR-EHR-SECTION.conformance_section.v0] CONTAINS OBSERVATION o
${query4}   SELECT o FROM SECTION CONTAINS OBSERVATION o CONTAINS CLUSTER c


*** Test Cases ***
1. Execute Ad Hoc Query With POST And Check Meta JSON Object
    #POST http://{base_url}/ehrbase/rest/openehr/v1/query/aql
    Execute Query   ${query1}
    Set Test Variable       ${expected_meta_keys}   ${expected_meta_keys_post}
    Meta JSON Object Checks
    Dictionary Should Not Contain Key   ${meta_obj}     _href

2. Execute Stored Query With GET And Check Meta JSON Object
    #GET http://{base_url}/ehrbase/rest/openehr/v1/query/{qualified_query_name}
    ${resp_qualified_query_name}     PUT /definition/query/{qualified_query_name}
    ...     query_to_store=${query2}     format=text
    GET /query/{qualified_query_name}
    ...     qualif_name=${resp_qualified_query_name}
    Set Test Variable       ${resp_body_actual}     ${resp}
    Set Test Variable       ${expected_meta_keys}   ${expected_meta_keys_get}
    Meta JSON Object Checks
    Should Be Equal As Strings      ${meta_obj['_href']}
    ...     ${BASEURL}/query/${resp_qualified_query_name}

3. Execute Ad Hoc Query With Get And Check Meta JSON Object
    #GET http://{base_url}/ehrbase/rest/openehr/v1/query/aql?q={query}
    Set Test Variable       ${payload}      ${query3}
    GET /query/aql?q={query}
    Set Test Variable       ${resp_body_actual}     ${response.json()}
    Set Test Variable       ${expected_meta_keys}   ${expected_meta_keys_get}
    Meta JSON Object Checks
    Should Be Equal As Strings      ${meta_obj['_href']}
    ...     ${BASEURL}/query/aql

4. Execute Ad Hoc Query With Get Limit 1 Offset 1 And Check Meta JSON Object
    #GET http://{base_url}/ehrbase/rest/openehr/v1/query/aql?q={query}
    GET /query/aql With Query Params    query=${query3}
    Set Test Variable       ${resp_body_actual}     ${response.json()}
    Set Test Variable       ${expected_meta_keys}   ${expected_meta_keys_get}
    Meta JSON Object Checks

5. Execute Stored Query With POST And Check Meta JSON Object
    #POST http://{base_url}/ehrbase/rest/openehr/v1/query/{qualified_query_name}
    ${resp_qualified_query_name}     PUT /definition/query/{qualified_query_name}
    ...     query_to_store=${query4}     format=text
    POST /query/{qualified_query_name}      qualif_name=${resp_qualified_query_name}
    Set Test Variable       ${resp_body_actual}     ${resp}
    Set Test Variable       ${expected_meta_keys}   ${expected_meta_keys_post}
    Meta JSON Object Checks

6. Execute Stored Query With GET Qualified Name And Version And Check Meta JSON Object
    #GET http://{base_url}/ehrbase/rest/openehr/v1/query/{qualified_query_name}/{version}
    ${resp_qualified_query_name_version}     PUT /definition/query/{qualified_query_name}/{version}
    ...     query_to_store=${query4}     format=text
    GET /query/{qualified_query_name}/{version}     qualif_name=${resp_qualified_query_name_version}
    Set Test Variable       ${resp_body_actual}     ${resp}
    Set Test Variable       ${expected_meta_keys}   ${expected_meta_keys_get}
    Meta JSON Object Checks
    Should Be Equal As Strings      ${meta_obj['_href']}
    ...     ${BASEURL}/query/${resp_qualified_query_name_version}

7. Execute Stored Query With POST Qualified Name And Version And Check Meta JSON Object
    #POST http://{base_url}/ehrbase/rest/openehr/v1/query/{qualified_query_name}/{version}
    ${resp_qualified_query_name_version}     PUT /definition/query/{qualified_query_name}/{version}
    ...     query_to_store=${query4}     format=text
    POST /query/{qualified_query_name}/{version}    qualif_name=${resp_qualified_query_name_version}
    Set Test Variable       ${resp_body_actual}     ${resp}
    Set Test Variable       ${expected_meta_keys}   ${expected_meta_keys_post}
    Meta JSON Object Checks


*** Keywords ***
Precondition
    Upload OPT For AQL      aql-conformance-ehrbase.org.v0.opt
    Create EHR For AQL
    Commit Composition For AQL      aql-conformance-ehrbase.org.v0_contains.json

Execute Query
    [Arguments]     ${query}
    Set AQL And Execute Ad Hoc Query    ${query}

Created Timestamp Checks
    [Arguments]     ${timestamp}
    @{timestamp_list}     Split String      ${timestamp}     T
    ${date_format}     Set Variable     ^\\d{4}-\\d{2}-\\d{2}
    Should Match Regexp     ${timestamp_list}[0]    ${date_format}
    @{time_list}    Split String    ${timestamp_list}[1]    .
    ${time_format}      Set Variable    ^\\d{2}:\\d{2}:\\d{2}
    Should Match Regexp     ${time_list}[0]    ${time_format}

Meta JSON Object Checks
    Set Test Variable   ${meta_obj}     ${resp_body_actual['meta']}
    Set Test Variable   ${q_str}        ${resp_body_actual['q']}
    Log     ${meta_obj}
    ${dict_keys}    Get Dictionary Keys     ${meta_obj}
    Lists Should Be Equal   ${expected_meta_keys}   ${dict_keys}
    Should Be Equal As Strings      ${meta_obj["_type"]}    RESULTSET
    Should Be Equal As Strings      ${meta_obj["_executed_aql"]}    ${q_str}
    Created Timestamp Checks        ${meta_obj["_created"]}

GET /query/aql With Query Params
    [Documentation]     Executes HTTP method GET on /query/aql?{params} endpoint
    [Arguments]     ${query}
    ${headers}      Create Dictionary
    ...     content=application/json
    ...     accept=application/json
    &{query_dict}       Create Dictionary       q=${query}
    &{query_params}     Create Dictionary       limit=1     offset=1
    ${resp}         Get On Session      ${SUT}      /query/aql      params=${query_dict}
                    ...     json=${query_params}
                    ...     headers=${headers}      expected_status=anything
                    Should Be Equal As Strings      ${resp.status_code}    ${200}
                    Set Test Variable   ${response}    ${resp}