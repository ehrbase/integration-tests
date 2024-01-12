*** Settings ***
Documentation   _Robot tests to check meta JSON object from AQL response._
...         ${\n}*Covers 2 cases*:
...         - _1. POST {ehrbase_url}/ehrbase/rest/openehr/v1/query/aql_
...         - _2. GET {ehrbase_url}/ehrbase/rest/openehr/v1/query/{qualified_query_name}_
...         ${\n}*Checks done*:
...         - 1.a. meta object has the following keys: _created, _executed_aql, _schema_version, _type
...         - 1.b. meta object don't have key _href
...         - 1.c. _created value has ISO 8601 format
...         - 1.d. _type value is RESULTSET
...         - 1.e. _executed_aql value is the same as value from q key (in AQL response)
...         ${\n}-----------
...         - 2.a. meta object has the following keys: _created, _executed_aql, _href, _schema_version, _type
...         - 2.b. _created value has ISO 8601 format
...         - 2.c. _type value is RESULTSET
...         - 2.d. _executed_aql value is the same as value from q key (in AQL response)
...         - 2.e. _href value is ${BASEURL}/query/{qualified_query_name}
...         ${\n}*Postcondition:* Delete EHR using ADMIN endpoint. This is deleting compositions linked to EHR.
Resource        ../../_resources/keywords/aql_keywords.robot
Resource        ../../_resources/keywords/aql_query_keywords.robot

#Suite Setup  Skip    enable Setup 'Precondition' if AQL checks are passing !!!
#Suite Teardown  Skip    enable Teardown 'Admin Delete EHR For AQL' if AQL checks are passing !!!
Suite Setup     Precondition        #enable this keyword if AQL checks are passing !!!
Suite Teardown  Admin Delete EHR For AQL       #enable this keyword if AQL checks are passing !!!


*** Test Cases ***
Execute Ad Hoc Query With POST And Check Meta JSON Object
    #POST http://localhost:8080/ehrbase/rest/openehr/v1/query/aql
    ${query1}   Set Variable
    ...     SELECT o FROM SECTION [openEHR-EHR-SECTION.conformance_section.v0] CONTAINS OBSERVATION o CONTAINS CLUSTER
    Execute Query   ${query1}
    @{expected_meta_keys}   Create List
    ...     _created    _executed_aql   _schema_version     _type
    Set Test Variable   ${expected_meta_keys}   ${expected_meta_keys}
    Meta JSON Object Checks
    Dictionary Should Not Contain Key   ${meta_obj}     _href

Execute Ad Hoc Query With GET And Check Meta JSON Object
    #GET http://localhost:8080/ehrbase/rest/openehr/v1/query/{qualified_query_name}
    ${query2}   Set Variable
    ...     SELECT o FROM SECTION CONTAINS OBSERVATION o CONTAINS CLUSTER
    ${resp_qualified_query_name}     PUT /definition/query/{qualified_query_name}
    ...     query_to_store=${query2}     format=text
    GET /query/{qualified_query_name}
    ...     qualif_name=${resp_qualified_query_name}
    Set Test Variable       ${resp_body_actual}     ${resp}
    @{expected_meta_keys}   Create List
    ...     _created    _executed_aql   _href   _schema_version     _type
    Set Test Variable   ${expected_meta_keys}   ${expected_meta_keys}
    Meta JSON Object Checks
    Should Be Equal As Strings      ${meta_obj['_href']}
    ...     ${BASEURL}/query/${resp_qualified_query_name}


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